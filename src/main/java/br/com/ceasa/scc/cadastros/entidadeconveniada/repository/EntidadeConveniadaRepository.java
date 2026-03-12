package br.com.ceasa.scc.cadastros.entidadeconveniada.repository;

import br.com.ceasa.scc.cadastros.entidadeconveniada.domain.EntidadeConveniada;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface EntidadeConveniadaRepository extends JpaRepository<EntidadeConveniada, UUID> {

    List<EntidadeConveniada> findAllByOrderByNomeAsc();

    Optional<EntidadeConveniada> findByCnpj(String cnpj);

    boolean existsByCnpj(String cnpj);
}