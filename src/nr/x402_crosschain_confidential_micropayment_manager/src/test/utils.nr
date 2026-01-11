use crate::X402CrossChainConfidentialMicropaymentManager;
use aztec::{
    protocol_types::address::AztecAddress, test::helpers::test_environment::TestEnvironment,
};

pub unconstrained fn setup_contract(
    with_account_contracts: bool,
) -> (&mut TestEnvironment, AztecAddress, AztecAddress, AztecAddress) {
    // Setup env, generate keys
    let mut env = TestEnvironment::new();
    let (owner, user) = if with_account_contracts {
        let owner = env.create_contract_account();
        let user = env.create_contract_account();
        (owner, user)
    } else {
        let owner = env.create_light_account();
        let user = env.create_light_account();
        (owner, user)
    };

    let contract_address = deploy_x402_crosschain_confidential_micropayment_manager_contract(&mut env, owner);

    (&mut env, contract_address, owner, user)
}

pub unconstrained fn deploy_x402_crosschain_confidential_micropayment_manager_contract(
    env: &mut TestEnvironment,
    owner: AztecAddress,
) -> AztecAddress {
    let initializer_call_interface = X402CrossChainConfidentialMicropaymentManager::interface().constructor(owner);
    let contract_address =
        env.deploy("@x402_crosschain_confidential_micropayment_manager/X402CrossChainConfidentialMicropaymentManager").with_public_initializer(owner, initializer_call_interface);

    contract_address
}
