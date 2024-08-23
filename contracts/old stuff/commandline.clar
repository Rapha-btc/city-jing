curl -X POST "https://api.hiro.so/v2/contracts/call-read/SPP3HM2E4JXGT26G1QRWQ2YTR5WT040S5NKXZYFC/stx-ft-swap/get-swap" \
  -H "Content-Type: application/json" \
  -d '{
    "sender": "SP29D6YMDNAKN1P045T6Z817RTE1AC0JAA99WAX2B",
    "arguments": ["u31"]
  }'

  curl -X POST "https://api.hiro.so/v2/contracts/call-read/SPP3HM2E4JXGT26G1QRWQ2YTR5WT040S5NKXZYFC/stx-ft-swap/get-swap" \
  -H "Content-Type: application/json" \
  -d '{
    "sender": "SP29D6YMDNAKN1P045T6Z817RTE1AC0JAA99WAX2B",
    "arguments": [
      "0x000000000000001f"
    ]
  }'