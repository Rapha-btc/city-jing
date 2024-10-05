Received event: {
  "apply": [
    {
      "block_identifier": {
        "hash": "0x43ce09be14f9a50bbbe43128d5a07e3f6883a6fef0e338bc305a9f35ad9a0c1c",
        "index": 167984
      },
      "metadata": {
        "bitcoin_anchor_block_identifier": {
          "hash": "0x00000000000000000000485533eec29f166b6cd2a7593a5b939b8549c2254921",
          "index": 863586
        },
        "confirm_microblock_identifier": null,
        "pox_cycle_index": 43174,
        "pox_cycle_length": 20,
        "pox_cycle_position": 5,
        "stacks_block_hash": "0x06ba133632b7cbed1e3f3de20353fb9f369d202b2be918c1ee81501df7df8346"
      },
      "parent_block_identifier": {
        "hash": "0x750cb36d8b788d3f4daa7ad325b09a8eb9eaaef83e33b0841cedb71d03accd7e",
        "index": 167983
      },
      "timestamp": 1727754068,
      "transactions": [
        {
          "metadata": {
            "description": "invoked: SP2EZ389HBPTTTXDS0360D3EWQMZ27H9ZST1D4EQ6.stx-ft::offer(u1000000, u1999998000, none, SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.nope, SP2EZ389HBPTTTXDS0360D3EWQMZ27H9ZST1D4EQ6.yin)",
            "execution_cost": {
              "read_count": 18,
              "read_length": 15415,
              "runtime": 249148,
              "write_count": 4,
              "write_length": 201
            },
            "fee": 10000,
            "kind": {
              "data": {
                "args": [
                  "u1000000",
                  "u1999998000",
                  "none",
                  "SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.nope",
                  "SP2EZ389HBPTTTXDS0360D3EWQMZ27H9ZST1D4EQ6.yin"
                ],
                "contract_identifier": "SP2EZ389HBPTTTXDS0360D3EWQMZ27H9ZST1D4EQ6.stx-ft",
                "method": "offer"
              },
              "type": "ContractCall"
            },
            "nonce": 37,
            "position": {
              "index": 225
            },
            "raw_tx": "0x0000000001040082879c32f9302762ed9b970505f3daaf5fae838c0000000000000025000000000000271000010fa4719c914c7b5efdc4ac73a963990fd332b097427d37a909f82023722ba9811dbb1793ca40feb9452e289d1f7c07f2162bf6880374b5cbf6499908c05f9d3d03020000000100021682879c32f9302762ed9b970505f3daaf5fae838c0500000000000f5f9f02169df1a1315db5ad75b900cc068ddcbd3e23c53fce067374782d6674056f666665720000000501000000000000000000000000000f42400100000000000000000000000077358c30090616c4a739e6e70be056920e5195e7ed579182c862aa046e6f706506169df1a1315db5ad75b900cc068ddcbd3e23c53fce0379696e",
            "receipt": {
              "contract_calls_stack": [],
              "events": [
                {
                  "data": {
                    "amount": "1000000",
                    "recipient": "SP2EZ389HBPTTTXDS0360D3EWQMZ27H9ZST1D4EQ6.stx-ft",
                    "sender": "SP218F71JZ4R2ERQDKEBGA1FKVAQNZBM3HK7W8EA7"
                  },
                  "position": {
                    "index": 461
                  },
                  "type": "STXTransferEvent"
                },
                {
                  "data": {
                    "contract_identifier": "SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.send-many-memo",
                    "topic": "print",
                    "value": "0x636174616d6172616e2073776170"
                  },
                  "position": {
                    "index": 462
                  },
                  "type": "SmartContractEvent"
                },
                {
                  "data": {
                    "amount": "7518",
                    "recipient": "SP2EZ389HBPTTTXDS0360D3EWQMZ27H9ZST1D4EQ6.yin",
                    "sender": "SP218F71JZ4R2ERQDKEBGA1FKVAQNZBM3HK7W8EA7"
                  },
                  "position": {
                    "index": 460
                  },
                  "type": "STXTransferEvent"
                },
                {
                  "data": {
                    "contract_identifier": "SP2EZ389HBPTTTXDS0360D3EWQMZ27H9ZST1D4EQ6.stx-ft",
                    "topic": "print",
                    "value": {
                      "contract_addre