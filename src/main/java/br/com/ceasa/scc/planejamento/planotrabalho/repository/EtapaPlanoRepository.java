package br.com.ceasa.scc.planejamento.planotrabalho.repository;

import br.com.ceasa.scc.planejamento.planotrabalho.domain.EtapaPlano;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface EtapaPlanoRepository extends JpaRepository<EtapaPlano, UUID> {

    List<EtapaPlano> findByMetaPlanoIdOrderByCreatedAtAsc(UUID metaPlanoId);
}