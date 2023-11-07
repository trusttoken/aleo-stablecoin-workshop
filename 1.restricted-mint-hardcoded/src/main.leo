program token.aleo {
    
    record token {
        owner: address,
        amount: u64,
    }

    transition mint(receiver: address, amount: u64) -> token {
        assert_eq(self.caller, aleo1n34an9qj0h732pceqct0ery9g2u6vgeut4xzgnxzjr72xmnl4yps8wlzul);

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
