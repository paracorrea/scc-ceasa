package br.com.ceasa.scc.convenios.convenio.repository;

import br.com.ceasa.scc.convenios.convenio.domain.Convenio;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ConvenioRepository extends JpaRepository<Convenio, UUID> {

    List<Convenio> findAllByOrderByDataInicioDesc();

    Optional<Convenio> findByNumero(String numero);

    boolean existsByNumero(String numero);
}