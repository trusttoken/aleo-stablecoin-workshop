
program token.aleo {
    record token {
        owner: address,
        amount: u64,
    }

    transition add(a: u64, b: u64) -> u64 {
        return a + b;
    }
}
