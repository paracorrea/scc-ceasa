package br.com.ceasa.scc.cadastros.unidadeadministrativa.repository;

import br.com.ceasa.scc.cadastros.unidadeadministrativa.domain.UnidadeAdministrativa;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface UnidadeAdministrativaRepository extends JpaRepository<UnidadeAdministrativa, UUID> {
    List<UnidadeAdministrativa> findByAtivoTrueOrderByNomeAsc();
}
