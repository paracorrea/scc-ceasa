package br.com.ceasa.scc.convenios.convenio.domain;

import br.com.ceasa.scc.cadastros.unidadeadministrativa.domain.UnidadeAdministrativa;
import br.com.ceasa.scc.planejamento.planotrabalho.domain.PlanoTrabalho;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "scc_convenio")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Convenio {

    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "plano_trabalho_id", nullable = false)
    private PlanoTrabalho planoTrabalho;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "unidade_administrativa_id")
    private UnidadeAdministrativa unidadeAdministrativa;

    @Column(nullable = false, length = 60, unique = true)
    private String numero;

    @Column(length = 60)
    private String protocolo;

    @Column(nullable = false, length = 1000)
    private String objeto;

    @Column(name = "data_assinatura")
    private LocalDate dataAssinatura;

    @Column(name = "data_inicio")
    private LocalDate dataInicio;

    @Column(name = "data_fim")
    private LocalDate dataFim;

    @Column(name = "valor_total", nullable = false, precision = 14, scale = 2)
    private BigDecimal valorTotal;

    @Column(nullable = false, length = 40)
    private String status;

    @Column(name = "created_at", nullable = false, insertable = false, updatable = false)
    private OffsetDateTime createdAt;

    @Column(name = "updated_at", nullable = false, insertable = false, updatable = false)
    private OffsetDateTime updatedAt;

    @PrePersist
    void prePersist() {
        if (status == null || status.isBlank()) {
            status = "ATIVO";
        }
        if (valorTotal == null) {
            valorTotal = BigDecimal.ZERO;
        }
    }
}