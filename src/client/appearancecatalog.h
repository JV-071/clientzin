#pragma once
#include <appearances.pb.h>
#include <functional>
#include <limits>
#include <stdexcept>
#include <string>
#include <vector>

namespace AppearanceCatalog {
inline otclient::protobuf::appearances::Appearances load(
    const std::vector<std::string>& files,
    const std::function<std::string(const std::string&)>& readFile)
{
    if (files.empty()) throw std::runtime_error("Catalog contains no appearance libraries");
    otclient::protobuf::appearances::Appearances merged;
    for (const auto& file : files) {
        const auto data = readFile(file);
        otclient::protobuf::appearances::Appearances library;
        if (data.size() > static_cast<size_t>(std::numeric_limits<int>::max()) ||
            !library.ParseFromArray(data.data(), static_cast<int>(data.size())))
            throw std::runtime_error("Invalid appearance library: " + file);
        // Preserve catalog order. ThingTypeManager applies the last definition of each ID.
        merged.MergeFrom(library);
    }
    return merged;
}
}
