package br.com.ceasa.scc.planejamento.planotrabalho.service;

import br.com.ceasa.scc.common.exception.NotFoundException;
import br.com.ceasa.scc.planejamento.planotrabalho.domain.MetaPlano;
import br.com.ceasa.scc.planejamento.planotrabalho.domain.PlanoTrabalho;
import br.com.ceasa.scc.planejamento.planotrabalho.repository.MetaPlanoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class MetaPlanoService {

    private final MetaPlanoRepository repository;
    private final PlanoTrabalhoService planoTrabalhoService;

    @Transactional(readOnly = true)
    public List<MetaPlano> listarPorPlano(UUID planoId) {
        return repository.findByPlanoTrabalhoIdOrderByCreatedAtAsc(planoId);
    }

    @Transactional(readOnly = true)
    public MetaPlano buscar(UUID id) {
        return repository.findById(id)
                .orElseThrow(() -> new NotFoundException("Meta do plano não encontrada."));
    }

    @Transactional
    public MetaPlano salvar(UUID planoId, MetaPlano meta) {
        PlanoTrabalho plano = planoTrabalhoService.buscar(planoId);

        if (meta.getId() == null) {
            meta.setPlanoTrabalho(plano);
            return repository.save(meta);
        }

        MetaPlano existente = buscar(meta.getId());
        existente.setDescricao(meta.getDescricao());
        return repository.save(existente);
    }
}