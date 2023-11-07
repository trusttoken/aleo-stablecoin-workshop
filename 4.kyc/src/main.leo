import multisig.leo;

program token.aleo {
    const MINT_FN: field = 1field;

    record token {
        owner: address,
        amount: u64,
    }

    record kyc {
        owner: address,
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

        return token {
            owner: args.receiver,
            amount: args.amount,
        };
    }

    transition transfer(kyc_: kyc, sender: token, receiver: address, amount: u64) -> (kyc, token, token) {
        let difference: u64 = sender.amount - amount;

        let remaining: token = token {
            owner: sender.owner,
            amount: difference,
        };

        let transferred: token = token {
            owner: receiver,
            amount: amount,
        };

        return (kyc { owner: kyc_.owner }, remaining, transferred);
    }

    transition register(age: u64, nationality: field, social_id: u64) -> kyc {
        assert(age >= 18u64);
        
        if (nationality == 1field) {
            assert(age >= 21u64);
        }

        if (nationality == 2field) {
            // etc
        }

        return kyc { owner: self.caller };
    }
}
