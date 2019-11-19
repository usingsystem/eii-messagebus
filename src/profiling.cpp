#include "eis/utils/profiling.h"
#include <algorithm>

eis::utils::Profiling::Profiling() {
    std::string prof_mode = std::string(getenv("PROFILING_MODE"));
    std::transform(prof_mode.begin(), prof_mode.end(), prof_mode.begin(),
    [](unsigned char c){ return std::tolower(c); });

    if(prof_mode.compare(std::string("true")) == 0){
        this->m_profiling_enabled = true;
    }
    else {
        this->m_profiling_enabled = false;
    }
}

bool eis::utils::Profiling::is_profiling_enabled() {
    return this->m_profiling_enabled;
}

void eis::utils::Profiling::add_profiling_ts(msg_envelope_t* meta, const char* key) {
    try {
        using namespace std::chrono;
        using time_stamp = std::chrono::time_point<std::chrono::system_clock,
                                           std::chrono::microseconds>;
        time_stamp curr_time = std::chrono::time_point_cast<microseconds>(system_clock::now());
        auto now_ms = std::chrono::time_point_cast<std::chrono::microseconds>(curr_time);
        auto epoch = now_ms.time_since_epoch();
        auto value = std::chrono::duration_cast<std::chrono::microseconds>(epoch);
        long duration = value.count();

        msg_envelope_elem_body_t* curr_time_body = msgbus_msg_envelope_new_integer(duration);

        if (curr_time_body == NULL) {
            throw "Failed to create profiling timestamp element";
        }
        msgbus_ret_t ret = msgbus_msg_envelope_put(meta, key, curr_time_body);
        if(ret != MSG_SUCCESS) {
            throw "Failed to wrap msgBody ito meta-data envelope";
        }
    } catch(std::exception& err){
        LOG_ERROR("%s",err);
    }

}


int64_t eis::utils::Profiling::get_curr_time_as_int_epoch() {
    using namespace std::chrono;
     using time_stamp = std::chrono::time_point<std::chrono::system_clock,
                                           std::chrono::microseconds>;
    time_stamp curr_time = std::chrono::time_point_cast<microseconds>(system_clock::now());
    auto now_ms = std::chrono::time_point_cast<std::chrono::microseconds>(curr_time);
    auto epoch = now_ms.time_since_epoch();
    auto value = std::chrono::duration_cast<std::chrono::microseconds>(epoch);
    long duration = value.count();
    return duration;
}

