## Workshop 5 - ZeFi

Project starting point [here](https://github.com/mxm-slt/aleo-workshop-base/tree/main).


## Command Dump

* Deployment and environment setup: 
    ```BASH
    # Deployer
    export NODEPK=
    export NODEVK=
    export NODEADDR=

    # User
    export NODE1PK=
    export NODE1VK=
    export NODE1ADDR=

    export ENDPOINT="https://api.explorer.provable.com/v1"
    export PROGRAM="token_vesting_linear_kaxxa123.aleo"

    dokojs deploy -n testnet token_vesting_linear_kaxxa123
    # at1fw2mf243mljxu5n50xmd3pkewq86lljw0wwk2202llrmkaustcfqql83y0
    ```

* We will test this using the compliant token developed in [workshop 2](../learn_and_earn_token_kaxxa123/README.md).

* We have some public balance so we first convert 1000 tokens to private...

* Token Owner public balance: <BR />
https://api.explorer.provable.com/v1/testnet/program/token_registry.aleo/mapping/authorized_balances/5549840544232916648920443503011857507709922718566142135562848179158375427711field

* Convert public to private:

    ```BASH
    snarkos  developer  execute  token_registry.aleo  transfer_public_to_private  \
        619083925159field  "${NODE1ADDR}"  1000u128 false \
        --private-key "${NODE1PK}"  \
        --query "${ENDPOINT}" \
        --broadcast "${ENDPOINT}/testnet/transaction/broadcast" \
        --priority-fee 1000 \
        --network 1
    # at1xhyw2grkr42a8vw4629uh6shqn476yvudncd7xjzj04e8vykwcqq4dklg7

    export ENCRECORD=record1qyqspmwfq7pv2s5flut09z9uua8qkftpdvrpc7pw6uyheu47vq0y79gwqsrxzmt0w4h8ggcqqgqspjyxtdq80mj0ke0gx48x32nxt9ck7knh7mpcdatmne3rq555p4qzpp6x76m9de0kjezrqqpqyqpdgh7jd8plahxtkw438t57zf8nf04qsuay265r6q3apqgp8ql8qh6rydy7pzq29sf523ht5gkygyesrp0ut9ut6sdv3hlwh93emydsj8m90p6x2unwv9k97ct4w35x7unf0fshg6t0de0hyet3w45hyetyyvqqyqgqs2qsslz22u5xu726gch46adpnxcts9n5hylkrqrgn27yetf4qvg3qct4w35x7unf0fjkghm4de6xjmprqqpqzqy2v3lrqqagx60jguw64xnh23x39z0pv766gnmhk54tu9r5p4kpp7g4m2dk23dxgl3k84cqg66w5unfyvgcttsrseysgrueqhhema6sgsetklg

    snarkos developer decrypt \
        --network 1 \
        --view-key ${NODE1VK} \
        --ciphertext ${ENCRECORD}
    ```
    ```JSON
    {
        owner: aleo16t4za3w2kmkntchsuennka7f2pjfsw3vvp66ckryfzv4zawu5vpss56rrz.private,
        amount: 1000u128.private,
        token_id: 619083925159field.private,
        external_authorization_required: false.private,
        authorized_until: 4294967295u32.private,
        _nonce: 2017518313333185050044388894703374776474080902111618076973371582800661667217group.public
    }    
    ```

* Use `token_vesting_linear_kaxxa123.aleo` to lock tokens. Where: <BR /> 
    `lock_id = 123field` <BR /> 
    `amount = 50u128`<BR /> 
    `receiver = sender`<BR /> 
    `block_start = block/height/latest` <BR /> 
    `block_length = 300u32`

    ```BASH
    export TOKEN="{owner: aleo16t4za3w2kmkntchsuennka7f2pjfsw3vvp66ckryfzv4zawu5vpss56rrz.private, amount: 1000u128.private, token_id: 619083925159field.private, external_authorization_required: false.private, authorized_until: 4294967295u32.private, _nonce: 2017518313333185050044388894703374776474080902111618076973371582800661667217group.public}"

    snarkos  developer  execute  ${PROGRAM} create_lock_private  \
        123field  "${TOKEN}"  50u128 "${NODE1ADDR}" 5591861u32  300u32 \
        --private-key "${NODE1PK}"  \
        --query "${ENDPOINT}" \
        --broadcast "${ENDPOINT}/testnet/transaction/broadcast" \
        --priority-fee 1000 \
        --network 1
    # at170jry75vesc5xqlsyj7shnyf3egfxy7vff78cpdvfp936kysmgqq9jarm8

    export ENCRECORD=record1qyqspdt0euq93vhyd62248r0rht0ua8t0p92zunx9rutcgwu3k3n2hcxqsrxzmt0w4h8ggcqqgqspt2j4fy65fv0k33fv2ll4d0kv5wcdvhqx70j9x9efn9vpxd9qqq2pp6x76m9de0kjezrqqpqyqqhsvjzuu5h56qf0jtxgkdql3sqm05vtcellmtu8c9atr8nsu9spwddhfyg70r9a75lq6z9ldwaze49yxkflhk76phm2x5fe0z0xkyq28m90p6x2unwv9k97ct4w35x7unf0fshg6t0de0hyet3w45hyetyyvqqyqgqlk5d5utud7x8thvzgz63hqe6z2l8aetssl2fdj3m4njdm7jlpyxpqct4w35x7unf0fjkghm4de6xjmprqqpqzq9av5ajk0kg2lj3qd34l5lm4t5k2pnjhawstuug9rrcdk6dxrfnp5qvyw0zt9ernlh3cpy7f55xsl57h3fk57mnnhzp5snzq8dw32asucerwz9

    snarkos developer decrypt \
        --network 1 \
        --view-key ${NODE1VK} \
        --ciphertext ${ENCRECORD}

    export ENCRECORD=record1qyqsqsdmeg0j9nyl500aj2dzthmrz325p8e8qquv65hld0slunvvf9cqqyrkcmmrdd0kjezrqqpqyq9j8kq8g40693nlxpnx033h5z0v3a3fdah4srfumx0ntc7ldj7cq3qa46v2qvwcr5luhngknxtakkdw7n06gjckcp0ra0geex2aqxhs7xywzuyngef0t8tjppvvx9gpqk8lthsndfr49engkcuz8z8tjdcp2r699m

    snarkos developer decrypt \
        --network 1 \
        --view-key ${NODE1VK} \
        --ciphertext ${ENCRECORD}
    ```

    Lock receipt:
    ```JSON
    {
        owner: aleo16t4za3w2kmkntchsuennka7f2pjfsw3vvp66ckryfzv4zawu5vpss56rrz.private,
        lock_id: 123field.private,
        _nonce: 550770094483787709633078967790803403465832233935734500968550223523217903128group.public
    } 
    ```

    Lock: <BR />
    https://api.explorer.provable.com/v1/testnet/program/token_vesting_linear_kaxxa123.aleo/mapping/locks/123field

    ```JSON
    {
        lock_id: 123field,
        token_id: 619083925159field,
        locked_amount: 50u128,
        claimed_amount: 0u128,
        start_block: 5591861u32,
        block_count_per_part: 0u32
    }
    ```

