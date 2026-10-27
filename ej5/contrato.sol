// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract CertificadosAcademicos {
    address public immutable emisor;

    struct Certificado {
        bool existe;
        bool revocado;
        uint64 fechaRegistro;
    }

    mapping(bytes32 => Certificado) private certificados;

    event CertificadoRegistrado(bytes32 indexed hash);
    event CertificadoRevocado(bytes32 indexed hash);

    modifier soloEmisor() {
        require(msg.sender == emisor, "No autorizado");
        _;
    }

    constructor() {
        emisor = msg.sender;
    }

    function calcularHash(string calldata texto)
        external pure returns (bytes32)
    {
        return keccak256(bytes(texto));
    }

    function registrarCertificado(bytes32 hash)
        external soloEmisor
    {
        require(hash != bytes32(0), "Hash invalido");
        require(!certificados[hash].existe, "Ya registrado");

        certificados[hash] = Certificado(
            true,
            false,
            uint64(block.timestamp)
        );
        emit CertificadoRegistrado(hash);
    }

    function verificarCertificado(bytes32 hash)
        external view returns (bool)
    {
        return certificados[hash].existe &&
               !certificados[hash].revocado;
    }

    function revocarCertificado(bytes32 hash)
        external soloEmisor
    {
        require(certificados[hash].existe, "No existe");
        require(!certificados[hash].revocado, "Ya revocado");

        certificados[hash].revocado = true;
        emit CertificadoRevocado(hash);
    }

    function consultarCertificado(bytes32 hash)
        external view returns (bool, bool, uint64)
    {
        Certificado storage c = certificados[hash];
        return (c.existe, c.revocado, c.fechaRegistro);
    }
}
