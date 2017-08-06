pragma solidity ^0.4.0;
contract Licita {

    struct Participar {
        uint peso;
        bool aceito;
        uint8 licitacao;
        address delegar;
    }
    struct Proposta {
        uint voteCount;
    }

    address blocoprojeto;
    mapping(address => Participar) voters;
    Proposta[] propostas;

    /// Criando uma nova Licita com $(_numPropostas) diferente propostas.
    function Licita(uint8 _numPropostas) {
        blocoprojeto = msg.sender;
        voters[blocoprojeto].peso = 1;
        propostas.length = _numPropostas;
    }

    /// Dê $(voter)o direito à licitacao nesta licita(dapps).
    /// Só pode ser chamado por $(blocoprojeto).
    function giveRightToVote(address voter) {
        if (msg.sender != blocoprojeto || voters[voter].aceito) return;
        voters[voter].peso = 1;
    }

    /// delegar sua licitacao para o voter $(to).
    function delegar(address to) {
        Participar storage sender = voters[msg.sender]; // Atribui referência
        if (sender.aceito) return;
        while (voters[to].delegar != address(0) && voters[to].delegar != msg.sender)
            to = voters[to].delegar;
        if (to == msg.sender) return;
        sender.aceito = true;
        sender.delegar = to;
        Participar storage delegateTo = voters[to];
        if (delegateTo.aceito)
            propostas[delegateTo.licitacao].voteCount += sender.peso;
        else
            delegateTo.peso += sender.peso;
    }

    /// Dê uma única votação para proposta $(proposta).
    function vote(uint8 proposta) {
        Participar storage sender = voters[msg.sender];
        if (sender.aceito || proposta >= propostas.length) return;
        sender.aceito = true;
        sender.licitacao = proposta;
        propostas[proposta].voteCount += sender.peso;
    }

    function winningProposal() constant returns (uint8 _winningProposta) {
        uint256 winningVoteCount = 0;
        for (uint8 proposta = 0; proposta < propostas.length; proposta++)
            if (propostas[proposta].voteCount > winningVoteCount) {
                winningVoteCount = propostas[proposta].voteCount;
                _winningProposta = proposta;
            }
    }
}
