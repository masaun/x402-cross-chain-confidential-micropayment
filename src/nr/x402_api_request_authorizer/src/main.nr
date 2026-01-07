use aztec::macros::aztec;
pub mod test;

/**
 * @title - X402ApiRequestAuthorizer using zkTLS
 * @dev - A contract that demonstrates API request authorization using zkTLS.
 */
#[aztec]
pub contract X402ApiRequestAuthorizer {
    // aztec library imports
    use aztec::{
        macros::{functions::{external, initializer, internal, view}, storage::storage},
        protocol_types::address::AztecAddress,
        state_vars::{PublicImmutable, PublicMutable},
    };

    /*************************
     *   @notice - Storage   *
     *************************/
    // @param owner The address of the owner
    // @param counter A numerical value
    #[storage]
    struct Storage<Context> {
        owner: PublicImmutable<AztecAddress, Context>,
        authorized_api_request_id: PublicMutable<u128, Context>,
    }

    /*****************************************
     *   @notice - Initialize & Constructor  *
     *****************************************/
    /// @dev Initialize the contract
    /// @param owner The address of the owner
    #[external("public")]
    #[initializer]
    fn constructor(owner: AztecAddress) {
        storage.owner.initialize(owner);
    }

    /***********************************
     *   @notice - External functions  *
     ***********************************/
    /// @dev - Authorizes an X402 API request using zkTLS (via the Primus old version for Cronos?)
    #[external("private")]
    fn authorize_x402_api_request() {
        let x402_api_request_authorizer = X402ApiRequestAuthorizer::at(context.this_address());

        // [TODO]: Implementation for authorizing an X402 API request using zkTLS goes here
    }


    /// @dev Increments the authorized API request id
    #[external("private")]
    fn increment_authorized_api_request_id() {
        let x402_api_request_authorizer = X402ApiRequestAuthorizer::at(context.this_address());
        x402_api_request_authorizer.increment_authorized_api_request_id_internal().enqueue(&mut context);
    }

    /************************************
     *   @notice - Internal functions   *
     ************************************/
    /// @dev Increments the authorized API request id
    #[external("public")]
    #[internal]
    fn increment_authorized_api_request_id_internal() {
        let current_authorized_api_request_id = storage.authorized_api_request_id.read();
        storage.authorized_api_request_id.write(current_authorized_api_request_id + 1);
    }

    /********************************
     *   @notice - View functions   *
     ********************************/
    /// @dev Retrieves the owner of the contract
    /// @return The owner of the contract
    #[external("public")]
    #[view]
    fn get_owner() -> AztecAddress {
        storage.owner.read()
    }

    /// @dev Retrieves the authorized API request id
    /// @return The current authorized API request id
    #[external("public")]
    #[view]
    fn get_authorized_api_request_id() -> u128 {
        storage.authorized_api_request_id.read()
    }
}
