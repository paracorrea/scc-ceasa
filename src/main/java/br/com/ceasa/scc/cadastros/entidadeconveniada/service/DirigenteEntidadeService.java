package br.com.ceasa.scc.cadastros.entidadeconveniada.service;

import br.com.ceasa.scc.cadastros.entidadeconveniada.domain.DirigenteEntidade;
import br.com.ceasa.scc.cadastros.entidadeconveniada.domain.EntidadeConveniada;
import br.com.ceasa.scc.cadastros.entidadeconveniada.repository.DirigenteEntidadeRepository;
import br.com.ceasa.scc.common.exception.BusinessException;
import br.com.ceasa.scc.common.exception.NotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class DirigenteEntidadeService {

    private final DirigenteEntidadeRepository repository;
    private final EntidadeConveniadaService entidadeConveniadaService;

    @Transactional(readOnly = true)
    public List<DirigenteEntidade> listarPorEntidade(UUID entidadeId) {
        return repository.findByEntidadeConveniadaIdOrderByNomeAsc(entidadeId);
    }

    @Transactional(readOnly = true)
    public DirigenteEntidade buscar(UUID id) {
        return repository.findById(id)
                .orElseThrow(() -> new NotFoundException("Dirigente não encontrado."));
    }

    @Transactional
    public DirigenteEntidade salvar(UUID entidadeId, DirigenteEntidade dirigente) {
        EntidadeConveniada entidade = entidadeConveniadaService.buscar(entidadeId);
        validarCpfUnico(entidadeId, dirigente);

        if (dirigente.getId() == null) {
            dirigente.setEntidadeConveniada(entidade);
            return repository.save(dirigente);
        }

        DirigenteEntidade existente = buscar(dirigente.getId());
        existente.setNome(dirigente.getNome());
        existente.setCpf(dirigente.getCpf());
        existente.setCargo(dirigente.getCargo());
       

        return repository.save(existente);
    }

    private void validarCpfUnico(UUID entidadeId, DirigenteEntidade dirigente) {
        repository.findByEntidadeConveniadaIdAndCpf(entidadeId, dirigente.getCpf())
                .ifPresent(existente -> {
                    if (dirigente.getId() == null || !existente.getId().equals(dirigente.getId())) {
                        throw new BusinessException("Já existe um dirigente com este CPF para esta entidade.");
                    }
                });
    }
}