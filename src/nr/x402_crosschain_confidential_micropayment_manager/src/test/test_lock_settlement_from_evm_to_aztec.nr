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
 * @notice - Test for locking settlement from EVM to Aztec
 **/
#[test]
unconstrained fn lock_settlement_from_evm_to_aztec_success() {
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

    // @dev - Call the lock_settlement_from_evm_to_aztec() of the X402CrossChainConfidentialMicropaymentManager contract
    let secret: Field = 1234567890u128.to_field();
    let origin_data_bytes: [u8; ORDER_DATA_LENGTH] = [0u8; ORDER_DATA_LENGTH];
    
    // @dev - Calculate the correct order_id from the order_data
    let order_data = OrderData::decode(origin_data_bytes);
    let order_id = order_data.id();
    let order_id_bytes: [u8; 32] = order_id.to_be_bytes();
    
    let filler_data_bytes: [u8; 32] = [0u8; 32];
    env.call_private(owner, x402_crosschain_confidential_micropayment_manager.lock_settlement_from_evm_to_aztec(
        gateway_contract_address, 
        secret, 
        order_id_bytes, 
        origin_data_bytes, 
        filler_data_bytes
    ));

    // #[external("private")]
    // fn lock_settlement_from_evm_to_aztec(
    //     aztec_gateway_7683_contract_address: AztecAddress,
    //     secret: Field,
    //     order_id_bytes: [u8; 32],
    //     origin_data_bytes: [u8; ORDER_DATA_LENGTH],
    //     filler_data_bytes: [u8; 32]
    // ) {




    // let authorized_api_request_id = env.view_public(x402_crosschain_confidential_micropayment_manager.get_authorized_api_request_id());
    // assert(authorized_api_request_id == 1);
}