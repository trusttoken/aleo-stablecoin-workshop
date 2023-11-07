import multisig.leo;

program token.aleo {
    const MINT_FN: field = 1field;
    const FREEZE_ADDRESS_FN: field = 1field;

    mapping frozen_addresses: address => bool;

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

    transition mint(ticket: multisig.leo/ticket.record, args: MintArgs) -> token {
        assert_eq(
            ticket.proposal.program_address,
            aleo16l909ch9c9zujjlthk47knk72zq0r4wd7eveqm8ukgta6cfszsgs4nd7p4 // address("token.aleo")
        );
        assert_eq(ticket.proposal.function_id, MINT_FN);
        assert_eq(ticket.proposal.args_hash, BHP256::hash_to_field(args));

        return token {
            owner: args.receiver,
            amount: args.amount,
        };
    }

    transition transfer(kyc: kyc, sender: token, receiver: address, amount: u64) -> (kyc, token, token) {
        let difference: u64 = sender.amount - amount;

        let remaining: token = token {
            owner: sender.owner,
            amount: difference,
        };

        let transferred: token = token {
            owner: receiver,
            amount: amount,
        };

        return (kyc, remaining, transferred) then finalize(sender.owner, receiver);
    }

    finalize transfer(sender: address, receiver: address) {
        assert(!Mapping::get_or_use(frozen_addresses, sender, false));
        assert(!Mapping::get_or_use(frozen_addresses, receiver, false));
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

    transition freeze_address(ticket_: multisig.leo/ticket.record, to_freeze: address) {
        assert_eq(
            ticket_.proposal.program_address,
            aleo16l909ch9c9zujjlthk47knk72zq0r4wd7eveqm8ukgta6cfszsgs4nd7p4 // address("token.aleo")
        );
        assert_eq(ticket_.proposal.function_id, FREEZE_ADDRESS_FN);
        assert_eq(ticket_.proposal.args_hash, BHP256::hash_to_field(to_freeze));

        return then finalize(to_freeze);
    }

    finalize freeze_address(to_freeze: address) {
        Mapping::set(frozen_addresses, to_freeze, true);
    }
}
