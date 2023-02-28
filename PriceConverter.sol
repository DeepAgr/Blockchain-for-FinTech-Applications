// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

// Why is this a library and not abstract?
// Why not an interface?
library PriceConverter {
    // We could make this public, but then we'd have to deploy it
    function getPriceIU() internal view returns (uint256) {
        // Goerli ETH / USD Address
        // https://docs.chain.link/docs/ethereum-addresses/
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0x605D5c2fBCeDb217D7987FC0951B5753069bC360
        );
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return uint256(answer);
    }

    function getPriceJU() internal view returns (uint256) {
        // Goerli ETH / USD Address
        // https://docs.chain.link/docs/ethereum-addresses/
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0x295b398c95cEB896aFA18F25d0c6431Fd17b1431
            // 0xBcE206caE7f0ec07b545EddE332A47C2F75bbeb3
        );
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return uint256(answer);
    }

    function getPriceEU() internal view returns (uint256) {
        // Goerli ETH / USD Address
        // https://docs.chain.link/docs/ethereum-addresses/
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
            // 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        );
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return uint256(answer);
    }

    function WEI_to_USD(uint256 ethAmount) internal view returns (uint256) {
        uint256 ethPrice = getPriceEU();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) /
            100000000000000000000000000;
        // the actual ETH/USD conversion rate, after adjusting the extra 0s.
        return ethAmountInUsd;
    }

    function USD_to_WEI(uint256 ethAmount) internal view returns (uint256) {
        uint256 ethPrice = getPriceEU();
        uint256 ethAmountInUsd = (ethAmount * 100000000000000000000000000) /
            ethPrice;
        // the actual ETH/USD conversion rate, after adjusting the extra 0s.
        return ethAmountInUsd;
    }

    // 1000000000
    function INR_to_USD(uint256 ethAmount) internal view returns (uint256) {
        uint256 ethPrice = getPriceIU();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        // the actual ETH/USD conversion rate, after adjusting the extra 0s.
        return ethAmountInUsd;
    }

    function USD_to_INR(uint256 ethAmount) internal view returns (uint256) {
        uint256 ethPrice = getPriceIU();
        uint256 ethAmountInUsd = (ethAmount * 1000000000000000000) / ethPrice;
        // the actual ETH/USD conversion rate, after adjusting the extra 0s.
        return ethAmountInUsd;
    }

    function JPY_to_USD(uint256 ethAmount) internal view returns (uint256) {
        uint256 ethPrice = getPriceJU();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        // the actual ETH/USD conversion rate, after adjusting the extra 0s.
        return ethAmountInUsd;
    }

    function USD_to_JPY(uint256 ethAmount) internal view returns (uint256) {
        uint256 ethPrice = getPriceJU();
        uint256 ethAmountInUsd = (ethAmount * 1000000000000000000) / ethPrice;
        // the actual ETH/USD conversion rate, after adjusting the extra 0s.
        return ethAmountInUsd;
    }

    function INR_to_JPY(uint256 ethAmount) internal view returns (uint256) {
        uint256 ethPrice = INR_to_USD(ethAmount);
        // the actual ETH/USD conversion rate, after adjusting the extra 0s.
        return USD_to_JPY(ethPrice);
    }

    function JPY_to_INR(uint256 ethAmount) internal view returns (uint256) {
        uint256 ethPrice = JPY_to_USD(ethAmount);
        // the actual ETH/USD conversion rate, after adjusting the extra 0s.
        return USD_to_INR(ethPrice);
    }
}
