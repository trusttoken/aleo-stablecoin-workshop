import multisig.leo;
import zpass.leo;

program token.aleo {
    const MINT_FN: field = 1field;
    const REGISTER_MULTISIG_FN: field = 2field;

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
        multisig.leo/burn(ticket_);

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

    transition register_zpass(identity_: zpass.leo/identity.record) -> kyc {
        // Check user is bigger than 17
        assert(identity_.age >= 18u8);
        
        if (identity_.nationality == 1field) {
            assert(identity_.age >= 21u8);
        }

        if (identity_.nationality == 2field) {
            // etc
        }

        return kyc { owner: self.caller };
    }

    transition register_multisig(ticket_: multisig.leo/ticket.record, receiver: address) -> kyc {
        assert_eq(
            ticket_.program_address,
            aleo16l909ch9c9zujjlthk47knk72zq0r4wd7eveqm8ukgta6cfszsgs4nd7p4 // address("token.aleo")
        );
        assert_eq(ticket_.function_id, REGISTER_MULTISIG_FN);
        assert_eq(ticket_.args_hash, BHP256::hash_to_field(receiver));
        multisig.leo/burn(ticket_);

        return kyc { owner: receiver };
    }
}
