import { useMemo, useState } from "react";
import { useAccount, useConnect, useDisconnect, useSelect, WalletProvider } from "aleo-hooks";

import WalletModal from "./components/WalletModal";

import {
  PuzzleWalletAdapter,
  LeoWalletAdapter,
  FoxWalletAdapter,
  SoterWalletAdapter,
  configureConnectionForPuzzle
} from 'aleo-adapters';
import "./App.css";

function connectWalletButton() {
  const account = useAccount();
  const { connect, address, connected, connecting, error } = useConnect();
  const { diconnect } = useDisconnect();
  const { select } = useSelect();
  const { isModalOpen, setIsModalOpen } = useState(false);

  const handleWalletSelect = (walletId) => {
    const walletAdapterMap = {
      "leo-wallet": "Leo Wallet",
      "puzzle-wallet": "Puzzle Wallet",
      "fox-wallet": "Fox Wallet",
      "soter-wallet": "Soter Wallet",
    };

    const adapterId = walletAdapterMap[walletId];

    if (!adapterId) {
      console.error(`Unknown wallet id:${walletId}`);
      return;
    }
    select(adapterId);
    setIsModalOpen(false);

    setTimeout(() => {
      connect(adapterId);
    }, 100);
  };

  const handleClick = () => {
    if (account.connected) {
      disconnect();
    } else {
      setIsModalOpen(true);
    }
  };

  return (
    <>
      <button className="connect-wallet-button"
        onClick={handleClick} >
        {account.connected ? "Disconnect Wallet" : "Connect Wallet"}
      </button>

      <WalletModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        onSelect={handleWalletSelect}
      />
    </>

  );

}

function App() {
  const wallets = useMemo(
    () => [
      new LeoWalletAdapter({
        appName: 'Aleo app',
      }),
      new PuzzleWalletAdapter({
        programIdPermissions: {
          ["AleoMainnet"]: ['dApp_1.aleo', 'dApp_1_import.aleo', 'dApp_1_import_2.aleo'],
          ["AleoTestnet"]: ['dApp_1_test.aleo', 'dApp_1_test_import.aleo', 'dApp_1_test_import_2.aleo']
        },
        appName: 'Aleo app',
        appDescription: 'A privacy-focused DeFi app'
      }),
      new FoxWalletAdapter({
        appName: 'Aleo app',
      }),
      new SoterWalletAdapter({
        appName: 'Aleo app',
      })
    ],
    [],
  );

  return (
    <WalletProvider wallets={wallets} autoConnect>
      <div className="App">
        Some content...
      </div>
    </WalletProvider>
  );
}


export default App;
