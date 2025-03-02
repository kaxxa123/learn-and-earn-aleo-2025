# Workshop 2 - Compliant Token Challenge

Check challenge details [here](https://github.com/demox-labs/aleo-standard-programs/tree/workshop-compliant-token/compliant_token).


## Compliance Rule 

### Background

CryptoInsure is an insurance company providing policies against 
price drops in the most popular cryptocurrencies ($ALEO, BTC or ETH).

A crypto hodler buys such an issurance whilst agreeing on a USD threshold 
price for the selected crypto. If the crypto price falls below the agreed 
threshold, the hodler becomes entitled to compensation.

### Implementation

CryptoInsure implements this solution using an Aleo Standards Compliant 
Token. The token is used as the compensation currency, whenever compensation 
is due.

To read the current cryptocurrency prices, and determine whether a policy holder
is entitled to compensation the token employs the `official_oracle_v2.aleo` program.


Workflow:

* After deploying the token, the hardcoded admin invokes the 
`initialize` and `setup_treasury` transitions. The latter will 
premine all tokens.

* On issuing a new insurance policy the admin invokes `issue_agreement` 
providing it all policy parameters. These are saved in a `Compensation` 
record owned by the crypto hodler. The parameters include:

    * `owner: address` - Crypto hodler address, to receive compensation
    * `amount: u128` - Compensation amount in Compliant tokens
    * `currency: u128` - Hash identifying currency (BTC/ETH/ALEO) as defined by `official_oracle_v2.aleo`, whose price is being insured
    * `price_limit: u128` - USD price at which owner becomes entitled to compensation
    * `expiry_block: u32` - Aleo block identifying Policy expiry. Users must submit their claim for compensation before this block is exceeded.

* If the insured cryptocurrency falls below the agreed threshold (`price_limit`), the client invokes the `claim` transition. This checks the current cryptocurrrency price at the oracle. If the price is found to be below the policy threshold, the agreed token `amount` is transferred to the policy holder. 

    To keep things simple the transition only checks the latest cryptocurrency price. Hence it is assumed that `claim` is invoked whilst the current price is still below the `price_limit` threshold.


* If a policy expires wihtout being claimed, CryptoInsure invokes the `cancel` transition to claim back locked funds. 


## Test Log

1. Deploy and Setup:

    ```bash
    # Admin
    export NODEPK=
    export NODEVK=
    export NODEADDR=

    # User
    export NODE1PK=
    export NODE1VK=
    export NODE1ADDR=

    export ENDPOINT="https://api.explorer.provable.com/v1"
    export PROGRAM="learn_and_earn_token_3515.aleo"


    snarkos  developer  deploy  ${PROGRAM}  \
        --private-key "${NODEPK}" \
        --path "./build/" \
        --query "${ENDPOINT}" \
        --broadcast "${ENDPOINT}/testnet/transaction/broadcast" \
        --priority-fee 10000 \
        --network 1

    # at1mjmy3ndq4kvclxrws4hl9kn59tqrgee9hcqdgygu86s6ejqe7q9s7suluj

    snarkos  developer  execute  ${PROGRAM} initialize  \
        --private-key "${NODEPK}"  \
        --query "${ENDPOINT}" \
        --broadcast "${ENDPOINT}/testnet/transaction/broadcast" \
        --priority-fee 10000 \
        --network 1

    # at1qyret839zqpe09hzdr094vca42ql8x5snp3paes3zuqtaaq7w5qqejjaca

    snarkos  developer  execute  ${PROGRAM} setup_treasury  \
        --private-key "${NODEPK}"  \
        --query "${ENDPOINT}" \
        --broadcast "${ENDPOINT}/testnet/transaction/broadcast" \
        --priority-fee 10000 \
        --network 1

    # at190yfnc8hsmjs0glvvkhph79wvplxfsuj0qldg084dl0u4cjpgg8qmv4wfu
    ```

1. Check current BTC price from the Oracle: <BR /> 

    Oracle sgx_attested_data is outdated on testnet, but for this example its fine: <BR /> 
    https://api.explorer.provable.com/v1/testnet/program/official_oracle_v2.aleo/mapping/sgx_attested_data/298333406399166460220216814461649767877u128

    ```JSON
    {
        data: 95629348263u128,
        attestation_timestamp: 1732805263u128
    }
    ```

    `timestamp` = `1732805263u128` = `Thursday, November 28, 2024 2:47:43 PM` <BR />
    `BTC price` = `95629348263u128` = `$95,629.348263`

    Oracle nitro_attested_data is not loaded with anything on testnet! <BR /> 
    https://api.explorer.provable.com/v1/testnet/program/official_oracle_v2.aleo/mapping/nitro_attested_data/298333406399166460220216814461649767877u128


1. Create Policy Agreement, where we pay `111111u128` if the BTC price goes below `95629348264u128`. This policy will expire if block `5859335u32` is reached. Note how the threshold is higher than what the oracle is quoting, so the player will be able to cash out the compensation.

    ```BASH
    # Get block height to compute expiry block
    #       https://api.explorer.provable.com/v1/testnet/block/height/latest
    #       5561227

    export BTC_ID="298333406399166460220216814461649767877u128"

    snarkos  developer  execute  ${PROGRAM} issue_agreement  \
        ${NODE1ADDR}  111111u128  ${BTC_ID}  95629348264u128 5859335u32 \
        --private-key "${NODEPK}"  \
        --query "${ENDPOINT}" \
        --broadcast "${ENDPOINT}/testnet/transaction/broadcast" \
        --priority-fee 10000 \
        --network 1

    # at1k9f95ljq02r30ug4ruz9m5zamg4d458lj4wy7qvvxx5a6y5y95qqtth686
    # record1qyqsp55yg26ugz6l6y6j2ts7wsyf20n4qcmzrxnt3g84kw8kpuayteqsqsrxzmt0w4h8ggcqqgqsppnnwsmn0xmtcqmm5etmqk8dncp3y5y204t0ztksxn5trgme7zqqpp3h2unjv4hxx7frqqpqzqq8urrcncsccmzp2ue7q4jglm4khu0qvder5v0ars5nva5makeepg9hqunfvdj47mrfd45hggcqqgqsqw0dzdxdxt6slzhtw4zlfxd0zkfqhnmgr9xd0yas8m7kf3s034syp3jhsurfwfu47cnvda3kkgcqqgqsphlz57q34r59p6weaaxalndcptvhusgrmkwee0ztyfvyvg2g5rcg3ax9wekay3zr0eqruvhyf6vgq9th0zmnq55nvkjna5erzwg03cgquf8wqp
    # 
    # https://api.explorer.provable.com/v1/testnet/program/learn_and_earn_token_3515.aleo/mapping/expiry_schedule/5859335u32
    # https://api.explorer.provable.com/v1/testnet/program/learn_and_earn_token_3515.aleo/mapping/total_committed/0u8

    snarkos developer decrypt \
        --network 1 \
        --view-key ${NODE1VK} \
        --ciphertext record1qyqsp55yg26ugz6l6y6j2ts7wsyf20n4qcmzrxnt3g84kw8kpuayteqsqsrxzmt0w4h8ggcqqgqsppnnwsmn0xmtcqmm5etmqk8dncp3y5y204t0ztksxn5trgme7zqqpp3h2unjv4hxx7frqqpqzqq8urrcncsccmzp2ue7q4jglm4khu0qvder5v0ars5nva5makeepg9hqunfvdj47mrfd45hggcqqgqsqw0dzdxdxt6slzhtw4zlfxd0zkfqhnmgr9xd0yas8m7kf3s034syp3jhsurfwfu47cnvda3kkgcqqgqsphlz57q34r59p6weaaxalndcptvhusgrmkwee0ztyfvyvg2g5rcg3ax9wekay3zr0eqruvhyf6vgq9th0zmnq55nvkjna5erzwg03cgquf8wqp
    ```
    ```JSON
    {
      owner: aleo16t4za3w2kmkntchsuennka7f2pjfsw3vvp66ckryfzv4zawu5vpss56rrz.private,
      amount: 111111u128.private,
      currency: 298333406399166460220216814461649767877u128.private,
      price_limit: 95629348264u128.private,
      expiry_block: 5859335u32.private,
      _nonce: 7488002928624207141071026366206650181186329377895939217850006604916733725839group.public
    }
    ```

1. Get the hash that allows reading balances at the token registry.

    ```BASH
    # Balance for policy holder is initially null..
    snarkos  developer  execute  ${PROGRAM} get_token_hash  \
        ${NODE1ADDR} \
        --private-key "${NODEPK}"  \
        --query "${ENDPOINT}" \
        --broadcast "${ENDPOINT}/testnet/transaction/broadcast" \
        --priority-fee 1000 \
        --network 1

    # at12ju5usapanzz40nd0fltkwjdlnxrvqt9dr0ll7napmrqmu4yuqpqf457hr
    # hash = 5549840544232916648920443503011857507709922718566142135562848179158375427711field
    # 
    #       https://api.explorer.provable.com/v1/testnet/program/token_registry.aleo/mapping/authorized_balances/5549840544232916648920443503011857507709922718566142135562848179158375427711field
    # 
    # null

    # "learn_and_earn_token_3515.aleo" = aleo1e6feqz9spv5vg9nk88h970wdh06r437pyrv22jymxkx7mw5xvs9s8j22kl
    snarkos  developer  execute  ${PROGRAM} get_token_hash  \
        "aleo1e6feqz9spv5vg9nk88h970wdh06r437pyrv22jymxkx7mw5xvs9s8j22kl" \
        --private-key "${NODEPK}"  \
        --query "${ENDPOINT}" \
        --broadcast "${ENDPOINT}/testnet/transaction/broadcast" \
        --priority-fee 1000 \
        --network 1

    # at138f0h4jcnszp79zy5whqm42tu28dswcznwyfhp9lq6x3c2237s8s3vxne6
    # hash = 4940731772529342062274211506669685387099347346189203315006147522262734483685field
    # 
    #       https://api.explorer.provable.com/v1/testnet/program/token_registry.aleo/mapping/authorized_balances/4940731772529342062274211506669685387099347346189203315006147522262734483685field
    # 
    #       "{\n  token_id: 619083925159field,\n  account: aleo1e6feqz9spv5vg9nk88h970wdh06r437pyrv22jymxkx7mw5xvs9s8j22kl,\n  balance: 1000000000000000u128,\n  authorized_until: 4294967295u32\n}"
    ```

1. Claim compensation

    ```BASH
    export RECORD_AGREE="{owner: aleo16t4za3w2kmkntchsuennka7f2pjfsw3vvp66ckryfzv4zawu5vpss56rrz.private, amount: 111111u128.private, currency: 298333406399166460220216814461649767877u128.private, price_limit: 95629348264u128.private, expiry_block: 5859335u32.private, _nonce: 7488002928624207141071026366206650181186329377895939217850006604916733725839group.public}"

    snarkos  developer  execute  ${PROGRAM} claim  \
        "${RECORD_AGREE}" \
        --private-key "${NODE1PK}"  \
        --query "${ENDPOINT}" \
        --broadcast "${ENDPOINT}/testnet/transaction/broadcast" \
        --priority-fee 1000 \
        --network 1

    # at1vsx5l89u6fxpkxv82duks6shlz6l6j9xp9lfnvmskzykfxmnvvysn8u53w
    # 
    # Balance for policy holder should now be 111111u128
    # 
    #       https://api.explorer.provable.com/v1/testnet/program/token_registry.aleo/mapping/authorized_balances/5549840544232916648920443503011857507709922718566142135562848179158375427711field
    # 
    # "{\n  token_id: 619083925159field,\n  account: aleo16t4za3w2kmkntchsuennka7f2pjfsw3vvp66ckryfzv4zawu5vpss56rrz,\n  balance: 111111u128,\n  authorized_until: 4294967295u32\n}"


    # Program balance should be 1000000000000000u128 - 111111u128
    #       https://api.explorer.provable.com/v1/testnet/program/token_registry.aleo/mapping/authorized_balances/4940731772529342062274211506669685387099347346189203315006147522262734483685field
    # 
    # "{\n  token_id: 619083925159field,\n  account: aleo1e6feqz9spv5vg9nk88h970wdh06r437pyrv22jymxkx7mw5xvs9s8j22kl,\n  balance: 999999999888889u128,\n  authorized_until: 4294967295u32\n}"
    # 
    ```

1. Transfer tokens using the `token_registry.aleo`
    ```BASH
    # User may transfer tokens using the token_registry.aleo program
    snarkos  developer  execute  token_registry.aleo  transfer_public  \
        619083925159field  "${NODEADDR}"  123u128 \
        --private-key "${NODE1PK}"  \
        --query "${ENDPOINT}" \
        --broadcast "${ENDPOINT}/testnet/transaction/broadcast" \
        --priority-fee 1000 \
        --network 1
    # at177psf88lw0msg3untxew6pmfapzpa3egp30wjse8vf88u0rq2vxs35xlgt
    # 
    # Sender balance:
    #       https://api.explorer.provable.com/v1/testnet/program/token_registry.aleo/mapping/authorized_balances/5549840544232916648920443503011857507709922718566142135562848179158375427711field
    #       "{\n  token_id: 619083925159field,\n  account: aleo16t4za3w2kmkntchsuennka7f2pjfsw3vvp66ckryfzv4zawu5vpss56rrz,\n  balance: 110988u128,\n  authorized_until: 4294967295u32\n}"
    # 
    # Receipient Balance:
    #       https://api.explorer.provable.com/v1/testnet/program/token_registry.aleo/mapping/authorized_balances/6487637713846189652905257029109780742128244515945629668883087315677180266771field
    #       "{\n  token_id: 619083925159field,\n  account: aleo1kmzwjeprmskjvhyjtmevq9fkanda57fn0af9fpe7830psw59dvrskmmdaj,\n  balance: 123u128,\n  authorized_until: 4294967295u32\n}"
    # 
    ```