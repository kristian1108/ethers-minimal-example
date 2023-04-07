// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

interface IReader {
    struct ChainStorage {
        PoolStorage pool;
        AssetStorage[] assets;
        DexStorage[] dexes;
        uint32 liquidityLockPeriod; // 1e0
        uint32 marketOrderTimeout; // 1e0
        uint32 maxLimitOrderTimeout; // 1e0
        uint256 lpDeduct; // MLP totalSupply = PRE_MINED - Σ_chains lpDeduct
        uint256 stableDeduct; // debt of stable coins = PRE_MINED - Σ_chains stableDeduct
        bool isPositionOrderPaused;
        bool isLiquidityOrderPaused;
    }

    struct PoolStorage {
        uint32 shortFundingBaseRate8H; // 1e5
        uint32 shortFundingLimitRate8H; // 1e5
        uint32 fundingInterval; // 1e0
        uint32 liquidityBaseFeeRate; // 1e5
        uint32 liquidityDynamicFeeRate; // 1e5
        uint96 mlpPriceLowerBound;
        uint96 mlpPriceUpperBound;
        uint32 lastFundingTime; // 1e0
        uint32 sequence; // 1e0. note: will be 0 after 0xffffffff
        uint32 strictStableDeviation; // 1e5
    }

    struct AssetStorage {
        // assets with the same symbol in different chains are the same asset. they shares the same muxToken. so debts of the same symbol
        // can be accumulated across chains (see Reader.AssetState.deduct). ex: ERC20(fBNB).symbol should be "BNB", so that BNBs of
        // different chains are the same.
        // since muxToken of all stable coins is the same and is calculated separately (see Reader.ChainState.stableDeduct), stable coin
        // symbol can be different (ex: "USDT", "USDT.e" and "fUSDT").
        bytes32 symbol;
        address tokenAddress; // erc20.address
        address muxTokenAddress; // muxToken.address. all stable coins share the same muxTokenAddress
        uint8 id;
        uint8 decimals; // erc20.decimals
        uint56 flags; // a bitset of ASSET_*
        uint32 initialMarginRate; // 1e5
        uint32 maintenanceMarginRate; // 1e5
        uint32 positionFeeRate; // 1e5
        uint32 liquidationFeeRate; // 1e5
        uint32 minProfitRate; // 1e5
        uint32 minProfitTime; // 1e0
        uint96 maxLongPositionSize;
        uint96 maxShortPositionSize;
        uint32 spotWeight;
        uint32 longFundingBaseRate8H; // 1e5
        uint32 longFundingLimitRate8H; // 1e5
        uint8 referenceOracleType;
        address referenceOracle;
        uint32 referenceDeviation;
        uint32 halfSpread;
        uint128 longCumulativeFundingRate; // Σ_t fundingRate_t
        uint128 shortCumulativeFunding; // Σ_t fundingRate_t * indexPrice_t
        uint96 spotLiquidity;
        uint96 credit;
        uint96 totalLongPosition;
        uint96 totalShortPosition;
        uint96 averageLongPrice;
        uint96 averageShortPrice;
        uint128 collectedFee;
        uint256 deduct; // debt of a non-stable coin = PRE_MINED - Σ_chains deduct
    }

    struct DexConfig {
        uint8 dexId;
        uint8 dexType;
        uint8[] assetIds;
        uint32[] assetWeightInDEX;
        uint32 dexWeight;
        uint256[] totalSpotInDEX;
    }

    struct DexState {
        uint8 dexId;
        uint256 dexLPBalance;
        uint256[] liquidityBalance;
    }

    struct DexStorage {
        uint8 dexId;
        uint8 dexType;
        uint8[] assetIds;
        uint32[] assetWeightInDEX;
        uint256[] totalSpotInDEX;
        uint32 dexWeight;
        uint256 dexLPBalance;
        uint256[] liquidityBalance;
    }

    struct SubAccountState {
        uint96 collateral;
        uint96 size;
        uint32 lastIncreasedTime;
        uint96 entryPrice;
        uint128 entryFunding;
    }

    function getChainStorage() external returns (ChainStorage memory chain);

    function getSubAccounts(bytes32[] memory subAccountIds) external pure returns (SubAccountState[] memory subAccounts);

    function getOrders(uint64[] memory orderIds) external pure returns (bytes32[3][] memory orders, bool[] memory isExist);

    function getSubAccountsAndOrders(bytes32[] memory subAccountIds, uint64[] memory orderIds) external pure returns (
        SubAccountState[] memory subAccounts,
        bytes32[3][] memory orders,
        bool[] memory isOrderExist
    );
}
