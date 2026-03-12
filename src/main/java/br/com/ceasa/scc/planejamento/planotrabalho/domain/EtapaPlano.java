package br.com.ceasa.scc.planejamento.planotrabalho.domain;

import br.com.ceasa.scc.cadastros.despesa.domain.Despesa;
import br.com.ceasa.scc.cadastros.despesa.domain.ItemDespesa;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "scc_etapa_plano")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EtapaPlano {

    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "meta_plano_id", nullable = false)
    private MetaPlano metaPlano;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "despesa_id")
    private Despesa despesa;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "item_despesa_id")
    private ItemDespesa itemDespesa;

    @Column(nullable = false, length = 1000)
    private String descricao;

    @Column(length = 120)
    private String duracao;

    @Column(precision = 14, scale = 2)
    private BigDecimal quantidade;

    @Column(nullable = false, precision = 14, scale = 2)
    private BigDecimal valor;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt;

    @PrePersist
    void prePersist() {
        OffsetDateTime now = OffsetDateTime.now();
        if (createdAt == null) createdAt = now;
        if (updatedAt == null) updatedAt = now;
    }

    @PreUpdate
    void preUpdate() {
        updatedAt = OffsetDateTime.now();
    }
}