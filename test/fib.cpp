// SPDX-FileCopyrightText: Michael Fisher @mfisher31
// SPDX-License-Identifier: MIT

static double fib (double x) {
    if (x < 2.0)
        return x;
    return fib (x - 2.0) + fib (x - 1.0);
}

int main() {
    fib (40.0);
    return 0;
}
