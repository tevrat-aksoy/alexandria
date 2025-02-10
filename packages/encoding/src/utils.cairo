use alexandria_math::{pow};

pub fn merge_u256_values(input: Span<u256>) -> Span<u256> {
    const BYTES_PER_U256: u256 = 32; // Each u256 is 32 bytes

    let mut combined: Array<u256> = Default::default();
    let mut current_combined: u256 = 0;

    let mut i = 0;
    let len = input.len();
    let mut current_size = 0;
    while i < len {
        let num_bytes = count_bytes(*input[i]);

        if current_size + num_bytes <= BYTES_PER_U256 {
            current_combined = combine_bytes(current_combined, *input[i], num_bytes);
            current_size += num_bytes;
        } else {
            // split the current value into two parts:
            let remaining_space = BYTES_PER_U256 - current_size;
            let (part1, part2) = split_value(*input[i], remaining_space);

            current_combined = combine_bytes(current_combined, part1, remaining_space);
            combined.append(current_combined);

            current_combined = part2;
            current_size = count_bytes(part2);
        }
        i = i + 1;
    };
    // Add the last combined value to the result array
    if current_size > 0 {
        combined.append(current_combined);
    }
    combined.span()
}

pub fn split_value(value: u256, size: u256) -> (u256, u256) {
    let shift = size * 8; // Convert bytes to bits
    let mask = pow(2, shift) - 1;

    let part1 = value & mask; // Extract the lower `size` bytes
    let part2 = value / pow(2, shift); // Extract the remaining bytes

    (part1, part2)
}

pub fn count_bytes(input: u256) -> u256 {
    let bytes_size = 256;
    let mut num_bytes = 0;
    let mut value = input;
    while (value > 0) {
        num_bytes += 1;
        value = value / bytes_size;
    };
    num_bytes
}

pub fn combine_bytes(b1: u256, b2: u256, size: u256) -> u256 {
    b1 * pow(256, size) + b2
}
