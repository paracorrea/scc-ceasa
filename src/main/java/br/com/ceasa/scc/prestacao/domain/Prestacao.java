package br.com.ceasa.scc.prestacao.domain;

import br.com.ceasa.scc.convenios.convenio.domain.Convenio;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "scc_prestacao")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Prestacao {


    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "convenio_id", nullable = false)
    private Convenio convenio;

    @Column(name = "mes_referencia", nullable = false)
    private LocalDate mesReferencia;

    @Column(nullable = false, length = 40)
    private String status;

    @Column(name = "created_at", insertable = false, updatable = false)
    private OffsetDateTime createdAt;

    @Column(name = "updated_at", insertable = false, updatable = false)
    private OffsetDateTime updatedAt;

    @PrePersist
    public void prePersist() {
        if (status == null || status.isBlank()) {
            status = "PENDENTE";
        }
        if (mesReferencia != null) {
            mesReferencia = mesReferencia.withDayOfMonth(1);
        }
    }
}