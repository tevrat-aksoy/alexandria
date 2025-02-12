use alexandria_math::{pow};
use core::iter::IntoIterator;
const BYTES_PER_U256: u32 = 32; // Each u256 is 32 bytes


pub fn merge_u256_arrays(first_array: Span<u256>, second_array: Span<u256>) -> Span<u256> {
    let mut merged_array: Array<u256> = Default::default();
    let mut processed_value: u256 = 0;
    let mut current_size = 0;

    let mut i = 0;
    let first_len = first_array.len();
    let second_len = second_array.len();

    let total_length = first_len + second_len;

    let mut current_value: u256 = 0;

    while i < total_length {
        current_value = if i < first_len {
            *first_array[i]
        } else {
            *second_array[i - first_len]
        };

        let element_size = count_bytes(current_value);

        if current_size + element_size <= BYTES_PER_U256 {
            processed_value = combine_bytes(processed_value, current_value, element_size);
            current_size += element_size;
        } else {
            // Split the current element
            let remaining_space = BYTES_PER_U256 - current_size;
            let (part1, part2) = split_value(current_value, remaining_space);

            processed_value = combine_bytes(processed_value, part1, remaining_space);
            merged_array.append(processed_value);

            processed_value = part2;
            current_size = count_bytes(part2);
        }
        i = i + 1;
    };

    if current_size > 0 {
        merged_array.append(processed_value);
    };
    merged_array.span()
}

pub fn split_value(value: u256, size: u32) -> (u256, u256) {
    let shift = (size * 8).into(); // Convert bytes to bits
    let mask = pow(2, shift) - 1;

    let part1 = value & mask; // Extract the lower `size` bytes
    let part2 = value / pow(2, shift); // Extract the remaining bytes

    (part1, part2)
}

pub fn count_bytes(input: u256) -> u32 {
    if input == 0 {
        return 1; // "0" should count as 1 byte
    };

    let bytes_size = 256;
    let mut num_bytes = 0;
    let mut value = input;
    while (value > 0) {
        num_bytes += 1;
        value = value / bytes_size;
    };
    num_bytes
}

pub fn combine_bytes(b1: u256, b2: u256, size: u32) -> u256 {
    b1 * pow(256, size.into()) + b2
}


pub fn calculate_array_byte_size(input: Span<u256>) -> u32 {
    let mut total_size = 0;
    let iter = input.into_iter();
    for value in iter {
        total_size += count_bytes(*value);
    };
    total_size
}
