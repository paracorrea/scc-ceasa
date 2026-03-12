package br.com.ceasa.scc.cadastros.entidadeconveniada.service;

import br.com.ceasa.scc.cadastros.entidadeconveniada.domain.EntidadeConveniada;
import br.com.ceasa.scc.cadastros.entidadeconveniada.repository.EntidadeConveniadaRepository;
import br.com.ceasa.scc.common.exception.BusinessException;
import br.com.ceasa.scc.common.exception.NotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class EntidadeConveniadaService {

    private final EntidadeConveniadaRepository repository;

    @Transactional(readOnly = true)
    public List<EntidadeConveniada> listar() {
        return repository.findAllByOrderByNomeAsc();
    }

    @Transactional(readOnly = true)
    public EntidadeConveniada buscar(UUID id) {
        return repository.findById(id)
                .orElseThrow(() -> new NotFoundException("Entidade conveniada não encontrada."));
    }

    @Transactional
    public EntidadeConveniada salvar(EntidadeConveniada entidade) {
        validarCnpjUnico(entidade);

        if (entidade.getId() == null) {
            return repository.save(entidade);
        }

        EntidadeConveniada existente = buscar(entidade.getId());
        existente.setNome(entidade.getNome());
        existente.setCnpj(entidade.getCnpj());
        existente.setEmail(entidade.getEmail());
        existente.setTelefone(entidade.getTelefone());
        existente.setCidade(entidade.getCidade());

        return repository.save(existente);
    }

    private void validarCnpjUnico(EntidadeConveniada entidade) {
        repository.findByCnpj(entidade.getCnpj())
                .ifPresent(existente -> {
                    if (entidade.getId() == null || !existente.getId().equals(entidade.getId())) {
                        throw new BusinessException("Já existe uma entidade conveniada cadastrada com este CNPJ.");
                    }
                });
    }
}