#ifndef D5D3CFB0_DF93_4234_B650_60F1D6B6A795
#define D5D3CFB0_DF93_4234_B650_60F1D6B6A795

#include <string_view>
#include <vector>

namespace saddle
{

namespace base64
{
constexpr unsigned char to_idx(char ch) {

    if (ch >= 'A' && ch <= 'Z') {
        return ch - 'A';
    }

    if (ch >= 'a' && ch <= 'z') {
        return (ch - 'a') + 26;
    }

    if (ch >= '0' && ch <= '9') {
        return (ch - '0') + 52;
    }

    if (ch == '+' || ch == '-') {
        return 62;
    }

    if (ch == '_' || ch == '/') {
        return 63;
    }

    return 255;
}


class decoder
{
    using result_type = std::vector<unsigned char>;
    using view_type = std::string_view;
    using buffer_type = unsigned char[4];

    result_type result;
    buffer_type converted{};
    unsigned char idx = 0;

    constexpr void convert()
    {
        for (unsigned char i = 0; i < idx - 1; ++i) {
            const unsigned char bit_offset = (i * 6) + 6;
            const unsigned char shift1 = 8 - (bit_offset % 8);
            const unsigned char shift2 = 6 - shift1;

            result.push_back((converted[i] << shift1) + (converted[i + 1] >> shift2));
        }
    }

public:
    decoder() { };
    explicit decoder(size_t hint)
    {
        result.reserve(8 * (1 + hint) / 6);
    };

    decoder(decoder &) = default;
    decoder(decoder &&) = default;
    decoder &operator=(decoder &) = default;
    decoder &operator=(decoder &&) = default;
    ~decoder() = default;

    constexpr bool feed(view_type sv)
    {
        for (view_type::value_type ch : sv) {
            /* The padding does nothing for us, just feed what
             * we have and return. */
            if (ch == '=') {
                convert();
                idx = 0;
                return true;
            }

            if (idx < 4) {
                converted[idx] = to_idx(ch);

                if (converted[idx] == 255) {
                    return false;
                }

                ++idx;

                continue;
            }

            convert();
            converted[0] = to_idx(ch);
            idx = 1;
        }

        return true;
    }

    result_type finish()
    {
        if (idx < 2 && idx != 0) {
            /* We require at least 2 letters or none on trailing. */
            return {};
        } else if (idx >= 2) {
            convert();
        }

        return std::move(result);
    }
};

} // namespace base64
} // namespace saddle

#endif /* D5D3CFB0_DF93_4234_B650_60F1D6B6A795 */
