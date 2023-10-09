#include <stdio.h>

union DoubleConverter {
    unsigned long long intValue;
    double doubleValue;
};

double ll_to_double(unsigned long long significand) {
    // Only support 0 < significand < 1 << 53.
    if (significand == 0 || significand >= 1ULL << 53)
        return -1.0;  // or handle the error in a way you prefer.

    // // naive version
    // int shifts = 0;

    // // Align the leading 1 of the significand to the hidden-1 position.
    // // Count the number of shifts required.
    // while ((significand & (1ULL << 52)) == 0)
    // {
    //     significand <<= 1;
    //     shifts++;
    // }

    // clz implementaion version
    int shifts = __builtin_clzll(significand) - 11;
    significand <<= shifts;

    // The number 1.0 has an exponent of 0, and would need to be
    // shifted left 52 times. IEEE-754 format requires a bias of 1023,
    // so the exponent field is given by the following expression:
    unsigned long long exponent = 1023 + 52 - shifts;

    // Now merge significand and exponent. Be sure to strip away
    // the hidden 1 in the significand.
    unsigned long long merged = (exponent << 52) | (significand & 0xFFFFFFFFFFFFF);

    // Use union for type conversion
    union DoubleConverter converter;
    converter.intValue = merged;

    return converter.doubleValue;
}

int main() {
    unsigned long long input = 1235655;
    double result = ll_to_double(input);

    printf("Result: %lf\n", result);

    return 0;
}