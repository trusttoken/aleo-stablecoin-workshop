

program zpass.aleo {
    record identity {
        owner: address,
        age: u8,
        nationality: field,
    }

    transition mint_identity(age: u8, nationality: field) -> identity {
        return identity {
            owner: self.caller,
            age: age,
            nationality: nationality,
        };
    }
}
