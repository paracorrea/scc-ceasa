package br.com.ceasa.scc.cadastros.entidadeconveniada.repository;

import br.com.ceasa.scc.cadastros.entidadeconveniada.domain.ContaBancariaEntidade;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ContaBancariaEntidadeRepository extends JpaRepository<ContaBancariaEntidade, UUID> {

    List<ContaBancariaEntidade> findByEntidadeConveniadaIdOrderByBancoAsc(UUID entidadeId);

    Optional<ContaBancariaEntidade> findByEntidadeConveniadaIdAndBancoAndAgenciaAndNumeroConta(
            UUID entidadeId, String banco, String agencia, String numeroConta);
}