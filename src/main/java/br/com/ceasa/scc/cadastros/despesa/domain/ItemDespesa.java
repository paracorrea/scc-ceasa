package br.com.ceasa.scc.cadastros.despesa.domain;

import jakarta.persistence.*;
import lombok.*;

import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "scc_item_despesa")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ItemDespesa {

    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "despesa_id", nullable = false)
    private Despesa despesa;

    @Column(nullable = false, length = 255)
    private String nome;

    @Column(nullable = false)
    private Integer ordem;

    @Column(nullable = false)
    private Boolean ativo;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt;

    @PrePersist
    void prePersist() {
        OffsetDateTime now = OffsetDateTime.now();
        if (createdAt == null) createdAt = now;
        if (updatedAt == null) updatedAt = now;
        if (ativo == null) ativo = true;
    }

    @PreUpdate
    void preUpdate() {
        updatedAt = OffsetDateTime.now();
    }
}