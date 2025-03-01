import credits.aleo;
import token_registry.aleo;
import official_oracle_v2.aleo;

// The 'learn_and_earn_token_3515' program.
program learn_and_earn_token_3515.aleo {

    // Constants defining the token parameters.
    const COMPLIANT_TOKEN_ID: field = 6190_8392_5159field; // Unique token identifier
    const NAME: u128 = 71619063553950105623552u128; // "compliant" encoded in ASCII
    const SYMBOL: u128 = 71619063553950105623552u128; // "compliant" encoded in ASCII
    const DECIMALS: u8 = 6u8; // Decimal places for the token
    const MAX_SUPPLY: u128 = 1_000_000_000_000_000u128; // Maximum supply of the token

    // Admin address with minting and issuing privileges
    const ADMIN_ADDRESS: address = aleo1kmzwjeprmskjvhyjtmevq9fkanda57fn0af9fpe7830psw59dvrskmmdaj; 

    // Number of blocks per day for epoch-based calculations
    const BLOCKS_IN_A_DAY: u32 = 28_800u32; 

    // Maximum value of a u32, used for transaction expiration
    const MAX_U32: u32 = 4294967295u32; 

    const ALEO_ID: u128 = 325436984254736568690754472542545613141u128;
    const BTC_ID: u128 = 298333406399166460220216814461649767877u128;
    const ETH_ID: u128 = 77627430694699498847744475143514157246u128;

    // Record defining the compensation a user is entitled to if the 
    // BTC/ETH/ALEO price drops below the specified amount.
    record Compensation {
        owner: address,     // The owner to receive compensation
        amount: u128,       // Compensation amount in tokens
        currency: u128,     // Hash identifying currency (BTC/ETH/ALEO) for which compensation is being issued
        price_limit: u128,  // Price at which owner becomes entitled to compensation
        expiry_block: u32,  // Aleo block identifying Compensation expiry. Once this block is exceeded  
                            // the compensation agreement is no longer be valid.
    }

    // Mapping to track whether the token has been minted (prevents multiple minting).
    mapping has_minted: u8 => bool;

    // Total amount of locked compensation
    mapping total_committed: u8 => u128;

    // An expiry schedule that keeps track of locked compensation amounts
    // This allows unlocking amounts for unclaimed expired compensation
    mapping expiry_schedule: u32 => u128;
    
    // Initializes the compliant token by registering it with the token registry.
    // Can only be called by the ADMIN_ADDRESS.
    async transition initialize() -> Future {
        assert_eq(self.caller, ADMIN_ADDRESS);

        // Register the token in the token registry
        let f0: Future = token_registry.aleo/register_token(
            COMPLIANT_TOKEN_ID,
            NAME,
            SYMBOL,
            DECIMALS,
            MAX_SUPPLY,
            false,
            self.address
        );

        return finalize_register_token(f0);
    }
    async function finalize_register_token(f0: Future) {
        f0.await();
    }

    // Mints the maximum supply of tokens to the Token program itself.
    // Can only be called once by the ADMIN_ADDRESS.
    async transition setup_treasury() -> Future {
        assert_eq(self.caller, ADMIN_ADDRESS);
        
        // Mint private tokens to the admin
        let f0: Future = token_registry.aleo/mint_public(
            COMPLIANT_TOKEN_ID,
            self.address,
            MAX_SUPPLY,
            MAX_U32
        );

        return finalize_setup_treasury(f0);
    }
    async function finalize_setup_treasury(f0: Future) {
        f0.await();

        let has_already_minted: bool = has_minted.contains(0u8);
        assert(!has_already_minted); // Ensure tokens are minted only once
        has_minted.set(0u8, true);
    }

    function isValidCurrency(currency: u128) -> bool {
        return (currency == ALEO_ID) || (currency == BTC_ID) || (currency == ETH_ID);
    }

    // Issue Compensation Token
    // Can only be called by the ADMIN_ADDRESS.
    async transition issue_agreement(
        owner: address,     // The owner to receive compensation
        amount: u128,       // Compensation amount in tokens
        currency: u128,     // Hash identifying currency (BTC/ETH/ALEO) for which compensation is being issued
        price_limit: u128,  // Price at which owner becomes entitled to compensation
        expiry_block: u32,  // Aleo block identifying Compensation expiry.
    ) -> (Compensation, Future) {
        assert_eq(self.caller, ADMIN_ADDRESS);
        assert(amount > 0u128);
        assert(isValidCurrency(currency));

        // Create a new spend limit record for the user
        let aggree: Compensation = Compensation {
            owner,
            amount,
            currency,
            price_limit,
            expiry_block
        };

        return (aggree, finalize_issue_agreement(amount,expiry_block));
    }
    async function finalize_issue_agreement(amount: u128, expiry_block: u32) {
        // Only issue aggreements after token minting is completed
        let has_already_minted: bool = has_minted.contains(0u8);
        assert(has_already_minted); // Ensure tokens are minted only once

        // Ensure expiry is in the future
        assert(expiry_block > block.height);

        // Make sure we are not running out of tokens
        // and update the commited total.
        let total_locked: u128 = Mapping::get_or_use(total_committed, 0u8, 0u128) + amount;
        assert(total_locked <= MAX_SUPPLY);
        Mapping::set(total_committed, 0u8, total_locked);

        // Set amount commited by expiry time
        let total_by_expiry: u128 = Mapping::get_or_use(expiry_schedule, expiry_block, 0u128) + amount;
        Mapping::set(expiry_schedule, expiry_block, total_by_expiry);
    }

    // User claims that compensation is due.
    // Can be called by anyone
    // https://docs.aleooracle.xyz/guide/attested_price_feed/#using-the-price-feed
    async transition claim(agree: Compensation) -> Future {
        assert_eq(self.caller, agree.owner);

        // Mint private tokens to the admin
        let f0: Future = token_registry.aleo/transfer_public(
            COMPLIANT_TOKEN_ID,
            agree.owner,
            agree.amount
        );

        return finalize_claim(agree.amount, agree.currency, agree.price_limit, agree.expiry_block, f0);
    }
    async function finalize_claim(
        amount: u128, 
        currency: u128, 
        price_limit: u128, 
        expiry_block :u32,
        f0: Future) {

        // Ensure expiry is in the future
        assert(expiry_block >= block.height);

        // ============================================
        // Ensure the current price for the crypto identified by currency
        // is indeed below the agreed price limit.

        // Read latest available value from the oracle
        // read data attested by an SGX enclave
        let sgx_oracle: AttestedData = official_oracle_v2.aleo/sgx_attested_data.get(currency);

        // Nitro enclave is not set on testnet so we disable its use...
        if official_oracle_v2.aleo/nitro_attested_data.contains(currency) {
            // read data attested by a Nitro enclave
            let nitro_oracle: AttestedData = official_oracle_v2.aleo/nitro_attested_data.get(currency);
            // compare the timestamps to identify which quote is newer to use the latest available
            let sgx_is_newer: bool = sgx_oracle.attestation_timestamp.gte(nitro_oracle.attestation_timestamp);
            // use the newer price
            let latest_available_price: u128 = sgx_is_newer ? sgx_oracle.data : nitro_oracle.data;
            assert(latest_available_price < price_limit);
        }
        else {
            assert(sgx_oracle.data < price_limit);
        }
        // ============================================

        // Update expiry schedule, deducting the amount claimed
        let total_by_expiry: u128 = Mapping::get(expiry_schedule, expiry_block) - amount;
        if total_by_expiry == 0u128 {
            Mapping::remove(expiry_schedule, expiry_block) ;
        }
        else {
            Mapping::set(expiry_schedule, expiry_block, total_by_expiry);
        }

        // Conclude transfer
        f0.await();
    } 

    // Recover funds tied to expired agreement
    // Can only be called by the ADMIN_ADDRESS.
    async transition cancel(expiry_block: u32) -> Future {
        return finalize_cancel(expiry_block);
    }
    async function finalize_cancel(expiry_block: u32) {
        // Ensure expiry is in the past
        assert(expiry_block < block.height);

        // Get amount of tokens expiring at this block height
        let amnt: u128 = Mapping::get_or_use(expiry_schedule, expiry_block, 0u128);
        if amnt > 0u128 {
            // Remove the entry from the expiry schedule
            Mapping::remove(expiry_schedule, expiry_block);

            // Deduct the amount from the total committed
            let total: u128 = Mapping::get(total_committed, 0u8) - amnt;
            Mapping::set(total_committed, 0u8, total);
        }
    }

    // Quick and dirty transition to see public balance 
    // without having to do the hashing
    transition get_token_hash(account: address) -> public field {

        let owner: TokenOwner = TokenOwner {
            account: account,
            token_id: COMPLIANT_TOKEN_ID

        };

        return BHP256::hash_to_field(owner);
    }
}