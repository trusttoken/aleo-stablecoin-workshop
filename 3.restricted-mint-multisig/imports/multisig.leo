import multisig.leo;

program token.aleo {
    const MINT_FN: field = 1field;

    record token {
        owner: address,
        amount: u64,
    }

    struct MintArgs {
        receiver: address,
        amount: u64,
    }

    transition mint(ticket_: multisig.leo/ticket.record, args: MintArgs) -> token {
        assert_eq(
            ticket_.program_address,
            aleo16l909ch9c9zujjlthk47knk72zq0r4wd7eveqm8ukgta6cfszsgs4nd7p4 // address("token.aleo")
        );
        assert_eq(ticket_.function_id, MINT_FN);
        assert_eq(ticket_.args_hash, BHP256::hash_to_field(args));
        multisig.leo/burn(ticket_);

        return token {
            owner: args.receiver,
            amount: args.amount,
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