package br.com.ceasa.scc.cadastros.despesa.repository;

import br.com.ceasa.scc.cadastros.despesa.domain.ItemDespesa;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface ItemDespesaRepository extends JpaRepository<ItemDespesa, UUID> {

    List<ItemDespesa> findByDespesaIdAndAtivoTrueOrderByOrdemAscNomeAsc(UUID despesaId);

    List<ItemDespesa> findByDespesaIdOrderByOrdemAscNomeAsc(UUID despesaId);
}