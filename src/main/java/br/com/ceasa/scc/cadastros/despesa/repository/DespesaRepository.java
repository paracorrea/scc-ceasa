package br.com.ceasa.scc.cadastros.despesa.repository;

import br.com.ceasa.scc.cadastros.despesa.domain.Despesa;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface DespesaRepository extends JpaRepository<Despesa, UUID> {

    List<Despesa> findAllByOrderByOrdemAscNomeAsc();
}