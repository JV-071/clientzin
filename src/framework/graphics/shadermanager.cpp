/*
 * Copyright (c) 2010-2026 OTClient <https://github.com/edubart/otclient>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#include "shadermanager.h"

#include "paintershaderprogram.h"
#include "framework/core/eventdispatcher.h"
#include "framework/core/resourcemanager.h"
#include "shader/shadersources.h"
#include <framework/platform/platformwindow.h>

ShaderManager g_shaders;

namespace
{
[[nodiscard]] std::string joinManagerShaderSources(const std::string_view first, const std::string_view second)
{
    std::string source;
    source.reserve(first.size() + second.size());
    source.append(first.data(), first.size());
    source.append(second.data(), second.size());
    return source;
}
}

void ShaderManager::init() { PainterShaderProgram::release(); }
void ShaderManager::terminate() { clear(); }

void ShaderManager::clear() {
    m_shaders.clear();
    m_shadersVector.clear();
    m_shaderIds.clear();
}

void ShaderManager::putShader(std::string name, const PainterShaderProgramPtr& shader) {
    if (m_shaders.contains(name))
        return;
    auto slot = m_shaderIds.find(name);
    if (slot == m_shaderIds.end()) {
        if (m_shadersVector.size() >= std::numeric_limits<uint8_t>::max()) {
            g_logger.error("Shader limit reached while registering '{}'", name);
            return;
        }
        const auto id = static_cast<uint8_t>(m_shadersVector.size() + 1);
        slot = m_shaderIds.emplace(name, id).first;
        m_shadersVector.push_back(nullptr);
    }
    shader->m_id = slot->second;
    m_shadersVector[slot->second - 1] = shader;
    m_shaders.emplace(std::move(name), shader);
}

void ShaderManager::removeShader(const std::string_view name) {
    // Run in creation order on the graphics dispatcher. Names retain their IDs
    // so recreating forge effects cannot exhaust or reassign live shader IDs.
    g_mainDispatcher.addEvent([this, name = std::string(name)] {
        if (const auto slot = m_shaderIds.find(name); slot != m_shaderIds.end())
            m_shadersVector[slot->second - 1].reset();
        m_shaders.erase(name);
    });
}

// Pure Vulkan mode has no GL context: compiling GLSL painter shaders is impossible and
// pointless (the Vulkan feeder ignores painter shader programs). Skipping creation here
// silences dozens of red "failed to compile shader" lines at startup.
static bool skipGlShaders()
{
    if (g_window.hasGLContext())
        return false;

    static bool logged = false;
    if (!logged) {
        logged = true;
        g_logger.info("Vulkan mode: GL painter shaders are skipped");
    }
    return true;
}

void ShaderManager::createShader(const std::string_view name, bool useFramebuffer)
{
    if (skipGlShaders())
        return;

    g_mainDispatcher.addEvent([this, name = std::string(name), useFramebuffer] {
        const auto& shader = std::make_shared<PainterShaderProgram>();
        shader->setUseFramebuffer(useFramebuffer);
        putShader(name, shader);
        return shader;
    });
}

void ShaderManager::createFragmentShader(const std::string_view name, const std::string_view file, bool useFramebuffer)
{
    if (skipGlShaders())
        return;

    const auto& filePath = g_resources.resolvePath(file.data());
    g_mainDispatcher.addEvent([this, name = std::string(name), filePath, useFramebuffer] {
        const auto& shader = std::make_shared<PainterShaderProgram>();
        shader->setUseFramebuffer(useFramebuffer);
        if (!shader)
            return;

        const auto& path = g_resources.guessFilePath(filePath, "frag");

        shader->addShaderFromSourceCode(ShaderType::VERTEX, joinManagerShaderSources(glslMainWithTexCoordsVertexShader, glslPositionOnlyVertexShader));
        if (!shader->addShaderFromSourceFile(ShaderType::FRAGMENT, path)) {
            g_logger.error("unable to load fragment shader '{}' from source file '{}'", name, path);
            return;
        }

        if (!shader->link()) {
            g_logger.error("unable to link shader '{}' from file '{}'", name, path);
            return;
        }

        putShader(name, shader);
    });
}

void ShaderManager::createFragmentShaderFromCode(const std::string_view name, const std::string_view code, bool useFramebuffer)
{
    if (skipGlShaders())
        return;

    g_mainDispatcher.addEvent([this, name = std::string(name), code = std::string(code), useFramebuffer] {
        const auto& shader = std::make_shared<PainterShaderProgram>();
        shader->setUseFramebuffer(useFramebuffer);
        if (!shader)
            return;

        shader->addShaderFromSourceCode(ShaderType::VERTEX, joinManagerShaderSources(glslMainWithTexCoordsVertexShader, glslPositionOnlyVertexShader));
        if (!shader->addShaderFromSourceCode(ShaderType::FRAGMENT, code)) {
            g_logger.error("unable to load fragment shader '{}'", name);
            return;
        }

        if (!shader->link()) {
            g_logger.error("unable to link shader '{}'", name);
            return;
        }

        putShader(name, shader);
    });
}

void ShaderManager::setupItemShader(const std::string_view name)
{
    g_mainDispatcher.addEvent([&, name = std::string(name)] {
        const auto& shader = getShader(name);
        if (!shader) return;
        shader->bindUniformLocation(ITEM_ID_UNIFORM, "u_ItemId");
    });
}

void ShaderManager::setupOutfitShader(const std::string_view name)
{
    g_mainDispatcher.addEvent([&, name = std::string(name)] {
        const auto& shader = getShader(name);
        if (!shader) return;
        shader->bindUniformLocation(OUTFIT_ID_UNIFORM, "u_OutfitId");
    });
}

void ShaderManager::setupMountShader(const std::string_view name)
{
    g_mainDispatcher.addEvent([&, name = std::string(name)] {
        const auto& shader = getShader(name);
        if (!shader) return;
        shader->bindUniformLocation(MOUNT_ID_UNIFORM, "u_MountId");
    });
}

void ShaderManager::setupMapShader(const std::string_view name)
{
    g_mainDispatcher.addEvent([&, name = std::string(name)] {
        const auto& shader = getShader(name);
        if (!shader) return;
        shader->bindUniformLocation(MAP_CENTER_COORD, "u_MapCenterCoord");
        shader->bindUniformLocation(MAP_GLOBAL_COORD, "u_MapGlobalCoord");
        shader->bindUniformLocation(MAP_WALKOFFSET, "u_WalkOffset");
        shader->bindUniformLocation(MAP_ZOOM, "u_MapZoom");
    });
}

void ShaderManager::setupTextShader(const std::string_view name)
{
    g_mainDispatcher.addEvent([&, name = std::string(name)] {
        const auto& shader = getShader(name);
        if (!shader) return;
        shader->bindUniformLocation(TEXT_OFFSET_UNIFORM, "u_Offset");
        shader->bindUniformLocation(TEXT_CENTER_UNIFORM, "u_Center");
    });
}

void ShaderManager::addMultiTexture(const std::string_view name, const std::string_view file)
{
    const auto& filePath = g_resources.resolvePath(file.data());
    g_mainDispatcher.addEvent([&, name = std::string(name), filePath] {
        const auto& shader = getShader(name);
        if (!shader) return;
        shader->addMultiTexture(filePath);
    });
}

PainterShaderProgramPtr ShaderManager::getShader(const std::string_view name)
{
    const auto it = m_shaders.find(name.data());
    if (it != m_shaders.end())
        return it->second;

    return nullptr;
}
