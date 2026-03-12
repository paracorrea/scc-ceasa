package br.com.ceasa.scc.cadastros.entidadeconveniada.repository;

import br.com.ceasa.scc.cadastros.entidadeconveniada.domain.DirigenteEntidade;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface DirigenteEntidadeRepository extends JpaRepository<DirigenteEntidade, UUID> {

    List<DirigenteEntidade> findByEntidadeConveniadaIdOrderByNomeAsc(UUID entidadeId);

    Optional<DirigenteEntidade> findByEntidadeConveniadaIdAndCpf(UUID entidadeId, String cpf);
}