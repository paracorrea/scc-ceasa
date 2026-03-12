package br.com.ceasa.scc.planejamento.planotrabalho.repository;

import br.com.ceasa.scc.planejamento.planotrabalho.domain.MetaPlano;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface MetaPlanoRepository extends JpaRepository<MetaPlano, UUID> {

    List<MetaPlano> findByPlanoTrabalhoIdOrderByCreatedAtAsc(UUID planoTrabalhoId);
}