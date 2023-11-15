program multisig.aleo {
    const ADD_SIGNER_FN: field = 1field;
    const CHANGE_REQUIRED_SIGNATURES_FN: field = 2field;

    mapping required_signatures: bool => u64;
    mapping signers: address => bool;
    mapping isSigned: UniqueSign => bool;
    mapping proposals: Proposal => u64;


    struct UniqueSign {
        user: address,
        proposal: Proposal
    }

    struct Proposal {
        program_address: address,
        function_id: field,
        args_hash: field,

    }

    record ticket {
        owner: address,
        program_address: address,
        function_id: field,
        args_hash: field,
    }

    transition mint_ticket(proposal: Proposal) -> ticket {
        return ticket {
            owner: self.caller,
            program_address: proposal.program_address,
            function_id: proposal.function_id,
            args_hash: proposal.args_hash,
        } then finalize(proposal);
    }

    finalize mint_ticket(proposal: Proposal) {
        let signatures: u64 = Mapping::get_or_use(proposals, proposal, 0u64);
        let min_signatures: u64 = Mapping::get_or_use(required_signatures, true, 0u64);
        assert(signatures >= min_signatures);
        Mapping::set(proposals, proposal, 0u64);
    }

    transition sign(proposal: Proposal) {
        return then finalize(self.caller, proposal);
    }

    finalize sign(caller: address, proposal: Proposal) {
        let unique:UniqueSign = UniqueSign {
            user: caller,
            proposal: proposal
        };

        assert(!Mapping::get(isSigned, unique));
        assert(Mapping::get(signers, caller));
        let signatures: u64 = Mapping::get_or_use(proposals, proposal, 0u64);
        Mapping::set(proposals, proposal, signatures + 1u64);
    }

    transition add_signer(ticket_: ticket, new_signer: address) {
        assert_eq(
            ticket_.program_address,
            aleo10frku8hz8zyyh03avmr2gjg6zyqz98g2fmcew96a50vxeke995qsuf90f2 // address("multisig.aleo")
        );
        assert_eq(ticket_.function_id, ADD_SIGNER_FN);
        assert_eq(ticket_.args_hash, BHP256::hash_to_field(new_signer));
        return then finalize(new_signer);
    }

    finalize add_signer(new_signer: address) {
        Mapping::set(signers, new_signer, true);
    }

    transition change_required_signatures(ticket_: ticket, new_required_signatures: u64) {
        assert_eq(
            ticket_.program_address,
            aleo10frku8hz8zyyh03avmr2gjg6zyqz98g2fmcew96a50vxeke995qsuf90f2 // address("multisig.aleo")
        );
        assert_eq(ticket_.function_id, CHANGE_REQUIRED_SIGNATURES_FN);
        assert_eq(ticket_.args_hash, BHP256::hash_to_field(new_required_signatures));

        return then finalize(new_required_signatures);
    }

    finalize change_required_signatures(new_required_signatures: u64) {
        Mapping::set(required_signatures, true, new_required_signatures);
    }

    transition burn(ticket_: ticket) {}
}