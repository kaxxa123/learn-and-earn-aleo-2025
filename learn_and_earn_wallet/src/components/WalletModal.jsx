import React from 'react';
import './WalletModal.css';

import leoWalletIcon from '../assets/leoWallet.png';
import puzzleWalletIcon from '../assets/puzzleWallet.png';
import soterWalletIcon from '../assets/soterWallet.png';
import foxWalletIcon from '../assets/foxWallet.svg';

const WalletModal = ({ isOpen, onClose, onWalletSelect }) => {
    if (!isOpen) return null;

    const wallets = [
        { id: 'leo-wallet', name: 'Leo Wallet', icon: leoWalletIcon },
        { id: 'puzzle-wallet', name: 'Puzzle Wallet', icon: puzzleWalletIcon },
        { id: 'soter-wallet', name: 'Soter Wallet', icon: soterWalletIcon },
        { id: 'fox-wallet', name: 'Fox Wallet', icon: foxWalletIcon },
    ];

    return (
        <div className="modal-overlay">
            <div className="wallet-modal">
                <div className="modal-header">
                    <h2>Connect Wallet</h2>
                    <button className="close-button" onClick={onClose}>✖</button>
                </div>
                <div className="wallet-options">
                    {wallets.map(wallet => (
                        <div
                            key={wallet.id}
                            className="wallet-option"
                            onClick={() => onWalletSelect(wallet.id)}
                        >
                            <img src={wallet.icon} alt={`${wallet.name} icon`} />
                            <span>{wallet.name}</span>
                        </div>
                    ))}
                </div>
            </div>
        </div>
    );
};

export default WalletModal;



