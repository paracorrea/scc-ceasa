package br.com.ceasa.scc.planejamento.planotrabalho.service;

import br.com.ceasa.scc.cadastros.entidadeconveniada.domain.EntidadeConveniada;
import br.com.ceasa.scc.cadastros.entidadeconveniada.service.EntidadeConveniadaService;
import br.com.ceasa.scc.common.exception.NotFoundException;
import br.com.ceasa.scc.planejamento.planotrabalho.domain.PlanoTrabalho;
import br.com.ceasa.scc.planejamento.planotrabalho.repository.PlanoTrabalhoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class PlanoTrabalhoService {

    private final PlanoTrabalhoRepository repository;
    private final EntidadeConveniadaService entidadeConveniadaService;

    @Transactional(readOnly = true)
    public List<PlanoTrabalho> listar() {
        return repository.findAllByOrderByCreatedAtDesc();
    }

    @Transactional(readOnly = true)
    public PlanoTrabalho buscar(UUID id) {
        return repository.findById(id)
                .orElseThrow(() -> new NotFoundException("Plano de trabalho não encontrado."));
    }

    @Transactional
    public PlanoTrabalho salvar(PlanoTrabalho plano) {
        EntidadeConveniada entidade = entidadeConveniadaService.buscar(plano.getEntidadeConveniada().getId());

        if (plano.getId() == null) {
            plano.setEntidadeConveniada(entidade);
            if (plano.getStatus() == null || plano.getStatus().isBlank()) {
                plano.setStatus("EM_ELABORACAO");
            }
            return repository.save(plano);
        }

        PlanoTrabalho existente = buscar(plano.getId());
        existente.setEntidadeConveniada(entidade);
        existente.setEdicao(plano.getEdicao());
        existente.setStatus(plano.getStatus());
        existente.setDescricao(plano.getDescricao());

        return repository.save(existente);
    }
}