use crate::{X402CrossChainConfidentialMicropaymentManager, test::utils};

#[test]
unconstrained fn increment_authorized_api_request_id_success() {
    let (env, x402_crosschain_confidential_micropayment_manager_contract_address, gateway_contract_address, owner, user1, user2) = utils::setup_contract(false);

    // @dev - Create the contract instance of the X402CrossChainConfidentialMicropaymentManager contract
    let x402_crosschain_confidential_micropayment_manager = X402CrossChainConfidentialMicropaymentManager::at(x402_crosschain_confidential_micropayment_manager_contract_address);

    env.call_private(owner,x402_crosschain_confidential_micropayment_manager.increment_authorized_api_request_id());

    let authorized_api_request_id = env.view_public(x402_crosschain_confidential_micropayment_manager.get_authorized_api_request_id());
    assert(authorized_api_request_id == 1);
}

#[test]
unconstrained fn does_it_fail_to_call_the_initializer() {
    let mut env = aztec::test::helpers::test_environment::TestEnvironment::new();

    let owner = env.create_light_account();

    let initializer_call_interface = X402CrossChainConfidentialMicropaymentManager::interface().constructor(owner);
    let x402_crosschain_confidential_micropayment_manager_deployer = env.deploy("@x402_crosschain_confidential_micropayment_manager/X402CrossChainConfidentialMicropaymentManager");
    let contract_address =
        x402_crosschain_confidential_micropayment_manager_deployer.with_public_initializer(owner, initializer_call_interface);

    env.call_private(owner, X402CrossChainConfidentialMicropaymentManager::at(contract_address).increment_authorized_api_request_id());

    let x402_crosschain_confidential_micropayment_manager = env.view_public(X402CrossChainConfidentialMicropaymentManager::at(contract_address).get_authorized_api_request_id());
    assert(x402_crosschain_confidential_micropayment_manager == 1);
}
