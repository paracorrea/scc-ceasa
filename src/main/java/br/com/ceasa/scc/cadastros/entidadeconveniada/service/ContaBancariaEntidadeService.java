package br.com.ceasa.scc.cadastros.entidadeconveniada.service;

import br.com.ceasa.scc.cadastros.entidadeconveniada.domain.ContaBancariaEntidade;
import br.com.ceasa.scc.cadastros.entidadeconveniada.domain.EntidadeConveniada;
import br.com.ceasa.scc.cadastros.entidadeconveniada.repository.ContaBancariaEntidadeRepository;
import br.com.ceasa.scc.common.exception.BusinessException;
import br.com.ceasa.scc.common.exception.NotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ContaBancariaEntidadeService {

    private final ContaBancariaEntidadeRepository repository;
    private final EntidadeConveniadaService entidadeConveniadaService;

    @Transactional(readOnly = true)
    public List<ContaBancariaEntidade> listarPorEntidade(UUID entidadeId) {
        return repository.findByEntidadeConveniadaIdOrderByBancoAsc(entidadeId);
    }

    @Transactional(readOnly = true)
    public ContaBancariaEntidade buscar(UUID id) {
        return repository.findById(id)
                .orElseThrow(() -> new NotFoundException("Conta bancária não encontrada."));
    }

    @Transactional
    public ContaBancariaEntidade salvar(UUID entidadeId, ContaBancariaEntidade conta) {
        EntidadeConveniada entidade = entidadeConveniadaService.buscar(entidadeId);
        validarContaUnica(entidadeId, conta);

        if (conta.getId() == null) {
            conta.setEntidadeConveniada(entidade);
            return repository.save(conta);
        }

        ContaBancariaEntidade existente = buscar(conta.getId());
        existente.setBanco(conta.getBanco());
        existente.setAgencia(conta.getAgencia());
        existente.setNumeroConta(conta.getNumeroConta());

        return repository.save(existente);
    }

    private void validarContaUnica(UUID entidadeId, ContaBancariaEntidade conta) {
        repository.findByEntidadeConveniadaIdAndBancoAndAgenciaAndNumeroConta(
                        entidadeId, conta.getBanco(), conta.getAgencia(), conta.getNumeroConta())
                .ifPresent(existente -> {
                    if (conta.getId() == null || !existente.getId().equals(conta.getId())) {
                        throw new BusinessException("Esta conta bancária já está cadastrada para a entidade.");
                    }
                });
    }
}