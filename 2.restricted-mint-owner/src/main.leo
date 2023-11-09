program token.aleo {
    mapping owner_: bool => address;
    mapping pending_owner: bool => address;

    record token {
        owner: address,
        amount: u64,
    }

    transition transfer_owner(new_owner: address) {
        return then finalize(self.caller, new_owner);
    }

    finalize transfer_owner(caller: address, new_owner: address) {
        assert_eq(Mapping::get_or_use(owner_, true, caller), caller);
        Mapping::set(pending_owner, true, new_owner);
    }

    transition accept_owner() {
        return then finalize(self.caller);
    }

    finalize accept_owner(new_owner: address) {
        assert_eq(Mapping::get(pending_owner, true), new_owner);
        Mapping::set(owner_, true, new_owner);
    }

    transition mint(receiver: address, amount: u64) -> token {
        return token {
            owner: receiver,
            amount: amount,
        } then finalize(self.caller);
    }

    finalize mint(caller: address) {
        assert_eq(Mapping::get(owner_, true), caller);
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
