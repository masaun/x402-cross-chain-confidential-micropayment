// @dev - aztec library imports
use aztec::{
    context::{PrivateContext, PublicContext},
    keys::getters::{get_nsk_app, get_public_keys},
    macros::{
        functions::{external, initializer, internal, view}, 
        storage::storage,
        notes::{
            note,
            custom_note
        },
    },
    //messages::logs::note,
    note::{
        note_emission::OuterNoteEmission,
        note_getter_options::{NoteGetterOptions, SortOrder},
        note_interface::{NoteProperties, NoteHash, NoteType},
        note_viewer_options::NoteViewerOptions,
        retrieved_note::RetrievedNote
    },
    protocol_types::{
        address::AztecAddress,
        constants::{
            GENERATOR_INDEX__NOTE_HASH, GENERATOR_INDEX__NOTE_NULLIFIER,
            GENERATOR_INDEX__PARTIAL_NOTE_VALIDITY_COMMITMENT,
        },
        hash::poseidon2_hash_with_separator,
        traits::{Deserialize, Hash, Packable, Serialize, ToField},
    },
    state_vars::{
        PublicImmutable, PublicMutable, DelayedPublicMutable,
        PrivateImmutable, PrivateMutable, PrivateSet, 
        Map
    },
    oracle::random::random,
    event::{
        event_emission::emit_event_in_private,
        event_selector::EventSelector,
        event_interface::EventInterface,
    },
    messages::message_delivery::MessageDelivery
};

// @dev - Import the X402CrossChainConfidentialMicropaymentManager contract
use crate::{
    X402CrossChainConfidentialMicropaymentManager, 
    test::utils
};

// @dev - Import the AztecGateway7683 contract (aztec_gateway_7683/src/main.nr)
use aztec_gateway_7683::{
    AztecGateway7683, 
    types::{
        events::{Filled, Open, Settled},
        helpers::InternalRCOParams,
        onchain_cross_chain_order::OnchainCrossChainOrder,
        order_data::{
            ORDER_DATA_LENGTH, ORDER_DATA_TYPE, OrderData, PRIVATE_ORDER,
            PRIVATE_ORDER_WITH_HOOK, PUBLIC_ORDER, PUBLIC_ORDER_WITH_HOOK,
        },
        resolved_cross_chain_order::{
            FILL_INSTRUCTIONS_MAX_INSTRUCTIONS, FillInstruction, MAX_SPENT_MAX_OUTPUTS,
            MIN_RECEIVED_MAX_OUTPUTS, Output, RESOLVED_CROSS_CHAIN_LENGTH,
            ResolvedCrossChainOrder,
        },
    },
};

/**
 * @notice - Test for unlocking settlement from Aztec to EVM
 **/
#[test]
unconstrained fn unlock_settlement_from_aztec_to_evm_success() {
    let (
        env, 
        x402_crosschain_confidential_micropayment_manager_contract_address, 
        gateway_contract_address, 
        owner, user1, user2
    ) = utils::setup_contract(false);

    // @dev - Create the X402CrossChainConfidentialMicropaymentManager contract instance
    let x402_crosschain_confidential_micropayment_manager = X402CrossChainConfidentialMicropaymentManager::at(x402_crosschain_confidential_micropayment_manager_contract_address);

    // @dev - Create the X402PrivatePaymentRouter contract instance
    //let aztec_gateway_7683 = AztecGateway7683::at(aztec_gateway_7683_contract_address);

    // @dev - Call the unlock_settlement_from_aztec_to_evm() of the X402CrossChainConfidentialMicropaymentManager contract
    let aztec_sender_address: AztecAddress = user1;
    let evm_l2_recipient_address: AztecAddress = user2;
    let evm_l2_asset_address: AztecAddress = user2;      // @dev - [TODO]: This should be replace with an actual asset address
    let amount: u128 = 1_000_00000u128;
    env.call_private(owner, x402_crosschain_confidential_micropayment_manager.unlock_settlement_from_aztec_to_evm(
        gateway_contract_address,
        aztec_sender_address,
        evm_l2_recipient_address,
        evm_l2_asset_address,
        amount
    ));

    // #[external("private")]
    // fn unlock_settlement_from_aztec_to_evm(
    //     aztec_gateway_7683_contract_address: AztecAddress,
    //     aztec_sender_address: AztecAddress,
    //     evm_l2_recipient_address: AztecAddress,
    //     evm_l2_asset_address: AztecAddress,
    //     amount: u128
    // ) {



    // let authorized_api_request_id = env.view_public(x402_crosschain_confidential_micropayment_manager.get_authorized_api_request_id());
    // assert(authorized_api_request_id == 1);
}