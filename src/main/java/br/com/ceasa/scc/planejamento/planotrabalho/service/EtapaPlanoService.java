package br.com.ceasa.scc.planejamento.planotrabalho.service;

import br.com.ceasa.scc.common.exception.NotFoundException;
import br.com.ceasa.scc.planejamento.planotrabalho.domain.EtapaPlano;
import br.com.ceasa.scc.planejamento.planotrabalho.domain.MetaPlano;
import br.com.ceasa.scc.planejamento.planotrabalho.repository.EtapaPlanoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class EtapaPlanoService {

    private final EtapaPlanoRepository repository;
    private final MetaPlanoService metaPlanoService;

    @Transactional(readOnly = true)
    public List<EtapaPlano> listarPorMeta(UUID metaId) {
        return repository.findByMetaPlanoIdOrderByCreatedAtAsc(metaId);
    }

    @Transactional(readOnly = true)
    public EtapaPlano buscar(UUID id) {
        return repository.findById(id)
                .orElseThrow(() -> new NotFoundException("Etapa do plano não encontrada."));
    }

    @Transactional
    public EtapaPlano salvar(UUID metaId, EtapaPlano etapa) {
        MetaPlano meta = metaPlanoService.buscar(metaId);

        if (etapa.getId() == null) {
            etapa.setMetaPlano(meta);
            return repository.save(etapa);
        }

        EtapaPlano existente = buscar(etapa.getId());
        existente.setDespesa(etapa.getDespesa());
        existente.setItemDespesa(etapa.getItemDespesa());
        existente.setDescricao(etapa.getDescricao());
        existente.setDuracao(etapa.getDuracao());
        existente.setQuantidade(etapa.getQuantidade());
        existente.setValor(etapa.getValor());

        return repository.save(existente);
    }
}