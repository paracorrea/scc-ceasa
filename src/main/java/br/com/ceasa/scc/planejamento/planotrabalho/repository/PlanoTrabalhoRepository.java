package br.com.ceasa.scc.planejamento.planotrabalho.repository;

import br.com.ceasa.scc.planejamento.planotrabalho.domain.PlanoTrabalho;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface PlanoTrabalhoRepository extends JpaRepository<PlanoTrabalho, UUID> {

    List<PlanoTrabalho> findAllByOrderByCreatedAtDesc();

    List<PlanoTrabalho> findByEntidadeConveniadaIdOrderByEdicaoDesc(UUID entidadeId);
}