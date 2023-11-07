program token.aleo {
    record token {
        owner: address,
        amount: u64,
    }

    transition mint(receiver: address, amount: u64) -> token {
        return token {
            owner: receiver,
            amount: amount,
        };
    }

    transition transfer(sender: token, receiver: address, amount: u64) -> (token, token) {
        let difference: u64 = sender.amount - amount;

        let remaining: token = token {
            owner: sender.owner,
            amount: difference,
        };

        let transferred: token = token {
            owner: receiver,
            amount: amount,
        };

        return (remaining, transferred);
    }
}
