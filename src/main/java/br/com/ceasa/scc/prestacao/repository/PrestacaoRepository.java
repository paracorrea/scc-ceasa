package br.com.ceasa.scc.prestacao.repository;

import br.com.ceasa.scc.prestacao.domain.Prestacao;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface PrestacaoRepository extends JpaRepository<Prestacao, UUID> {

    List<Prestacao> findAllByOrderByMesReferenciaDesc();

    Optional<Prestacao> findByConvenioIdAndMesReferencia(UUID convenioId, LocalDate mesReferencia);
}